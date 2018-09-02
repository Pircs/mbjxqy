local tbClass = Ui.HyperTextHandle
local tbWarpText = {}
local tbClickHandle = {}
function tbClass:Handle(szText, posX, posY)
  local tbLinkOper, szParam = self:Analysis(szText)
  if not tbLinkOper then
    return
  end
  return tbLinkOper:HandleClick(szParam, posX, posY)
end
function tbClass:AttachText(szText)
  local i = 0
  local j = 0
  local szTextRet = szText
  while true do
    i, j = string.find(szText, "%[url=.-%]", i)
    if i == nil then
      break
    end
    local szUrl = string.sub(szText, i + 5, j - 1)
    local tbLinkOper, szParam = self:Analysis(szUrl)
    local szAttach = tbLinkOper:WarpText(szParam) or ""
    szAttach = string.format("[i][u]<%s>[/u][/i]", szAttach)
    szText = string.sub(szText, 1, i - 1) .. szAttach .. string.sub(szText, j + 1, -1)
    i = i + string.len(szAttach)
  end
  return szText
end
function tbClass:Analysis(szText)
  szText = Lib:StrTrim(szText, "\"")
  local nStart, nEnd = string.find(szText, "%[url=.-%]", i)
  if nStart then
    szText = string.sub(szText, nStart + 5, nEnd - 1)
  end
  local szType, szParam = string.match(szText, "^[ \t]*([^ \t,]+):(.*)$")
  if not szType or not self.tbLinkClass[szType] then
    print("[HyperTextHandle] Analysis ERR ?? ", szText)
    return
  end
  return self.tbLinkClass[szType], szParam, szType
end
local tbLinkTest = {}
local FindEquipName = function(szText)
  return "神龙甲"
end
function tbLinkTest:WarpText(szParam)
  local szRet = ""
  local szName, level, strength = tbParam[1], tbParam[2], tbParam[3]
  szRet = szRet .. FindEquipName(szName)
  if 3 < tonumber(level) then
    szRet = "[b]" .. szRet .. "[/b]"
  end
  if tonumber(level) > 5 then
    szRet = "[ffcc00]" .. szRet .. "[-]"
  end
  return szRet
end
function tbLinkTest:HandleClick(szParam, nX, nY)
  print("Show EquipTip", szParam, nX, nY)
end
local fnGetNpcMap = function(nNpcTemplateId)
  local tbMap = {
    me.nMapTemplateId
  }
  if me.nMapTemplateId ~= 10 then
    table.insert(tbMap, 10)
  end
  for _, nMapTemplateId in ipairs(tbMap) do
    local tbCityNpc = Map:GetMapNpcInfoByNpcTemplate(nMapTemplateId, nNpcTemplateId) or {}
    if next(tbCityNpc) then
      return nMapTemplateId
    end
  end
end
local tbLinkNpc = {}
function tbLinkNpc:WarpText(szParam)
  local szDesc, nNpcTemplateId = string.match(szParam, "^[\t]*([^\t,]+)[\t,][ \t]*(%d+)[ \t,]")
  if not szDesc then
    return "nil"
  end
  if szDesc == "" then
    nNpcTemplateId = tonumber(nNpcTemplateId)
    szDesc = KNpc.GetNameByTemplateId(nNpcTemplateId) or ""
  end
  return szDesc
end
function tbLinkNpc:AnalysisParam(szParam)
  local szDesc, nNpcTemplateId, nMapTemplateId = string.match(szParam, "^[\t]*([^\t,]+)[\t]*,[ \t]*(%d+)[ \t]*,[ \t]*(%d*)")
  if not szDesc then
    Log("[HyperTextHandle] tbLinkNpc HandleClick ERR ?? ", szParam)
    return
  end
  nNpcTemplateId = tonumber(nNpcTemplateId)
  nMapTemplateId = tonumber(nMapTemplateId) > 0 and tonumber(nMapTemplateId) or fnGetNpcMap(nNpcTemplateId)
  if not nMapTemplateId or not nNpcTemplateId then
    Log("HyperTextHandle] tbLinkNpc HandleClick Find Npc ERR ?? ", nNpcTemplateId, nMapTemplateId)
    return
  end
  local nX, nY, nNpcNearLen = AutoPath:GetNpcPos(nNpcTemplateId, nMapTemplateId, true)
  return nNpcTemplateId, nMapTemplateId, nX, nY, nNpcNearLen
end
function tbLinkNpc:HandleClick(szParam, nX, nY)
  local nNpcTemplateId, nMapTemplateId, nX, nY = self:AnalysisParam(szParam)
  if not nMapTemplateId then
    return
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_CLICK_LINK_NPC, nNpcTemplateId, nMapTemplateId)
  return AutoPath:GotoAndCall(nMapTemplateId, nX, nY, function()
    self:OnFindNpc(nNpcTemplateId)
  end)
end
function tbLinkNpc:OnFindNpc(nNpcTemplateId)
  local tbNpcList = KNpc.GetAroundNpcList(me.GetNpc(), Npc.DIALOG_DISTANCE)
  for _, pNpc in pairs(tbNpcList or {}) do
    if pNpc.nTemplateId == nNpcTemplateId then
      Operation:SimpleTap(pNpc.nId)
      return
    end
  end
end
local UnpackParam = function(szParam, nCount)
  assert(nCount > 1)
  local szMatch = "^"
  for i = 1, nCount - 1 do
    szMatch = szMatch .. "[ \t]*([^\t,]+)[ \t]*,"
  end
  szMatch = szMatch .. "[ \t]*([^ \t].*[^ \t]?)[ \t]*$"
  return string.match(szParam, szMatch)
end
local function GoAndDoSomething(nMapTemplateId, nPosX, nPosY, szExtCmd, szExtParam, nNearLength)
  local function fnDoSomething()
    local tbCmd = tbClass.tbLinkClass[szExtCmd]
    assert(tbCmd, string.format("%s_%s", szExtCmd, szExtParam))
    tbCmd:HandleClick("test," .. szExtParam)
  end
  AutoPath:GotoAndCall(nMapTemplateId, nPosX, nPosY, fnDoSomething, nNearLength)
end
local tbNpcPath = {}
function tbNpcPath:AnalysisParam(szParam)
  local tbPath = {}
  for w in string.gmatch(szParam, "<%d*,%d*,%d*>") do
    local nMapTemplateId, nX, nY = string.match(w, "(%d+),(%d+),(%d+)")
    table.insert(tbPath, {
      tonumber(nMapTemplateId),
      tonumber(nX),
      tonumber(nY)
    })
  end
  local nNpcTemplateId, nMapTemplateId, nCloseLen = string.match(szParam, "^(%d+),(%d+),(%d+)")
  nNpcTemplateId = tonumber(nNpcTemplateId)
  nMapTemplateId = tonumber(nMapTemplateId)
  nCloseLen = tonumber(nCloseLen)
  local nX, nY, nWalkNearLen = AutoPath:GetNpcPos(nNpcTemplateId, nMapTemplateId, true)
  local _, nMyX, nMyY = me.GetWorldPos()
  if Lib:GetDistsSquare(nX, nY, nMyX, nMyY) <= nCloseLen ^ 2 then
    tbPath = {}
  end
  table.insert(tbPath, {
    nMapTemplateId,
    nX,
    nY
  })
  return nNpcTemplateId, tbPath, nWalkNearLen
end
local tbLinkPos = {}
function tbLinkPos:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbLinkPos:HandleClick(szParam, nX, nY)
  local szDesc, nMapTemplateId, nPosX, nPosY = UnpackParam(szParam, 4)
  if not szDesc then
    Log("[HyperTextHandle] tbLinkPos HandleClick ERR ?? ", szParam)
    return
  end
  return AutoPath:GotoAndCall(tonumber(nMapTemplateId), tonumber(nPosX), tonumber(nPosY), nil, nil, tonumber(nMapTemplateId))
end
local tbOpenWindow = {}
function tbOpenWindow:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbOpenWindow:HandleClick(szParam, nX, nY)
  local szDesc, szUiName, szUiParam = UnpackParam(szParam, 3)
  if not szDesc then
    szDesc, szUiName = UnpackParam(szParam, 2)
  end
  if not szDesc then
    Log("[HyperTextHandle] tbOpenWindow HandleClick ERR ?? ", szParam)
    return
  end
  local tbParam = {}
  if szUiParam then
    tbParam = loadstring(string.format("return {%s}", szUiParam))()
  end
  return Ui:OpenWindow(szUiName, unpack(tbParam))
end
local tbCloseWindow = {}
function tbCloseWindow:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbCloseWindow:HandleClick(szParam, nX, nY)
  local szDesc, szUiName = UnpackParam(szParam, 2)
  if not szDesc then
    Log("[HyperTextHandle] tbCloseWindow HandleClick ERR ??", szParam)
    return
  end
  return Ui:CloseWindow(szUiName)
end
local tbTaskItem = {}
function tbTaskItem:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbTaskItem:HandleClick(szParam, nX, nY)
  local szDesc, nTaskId = UnpackParam(szParam, 2)
  if not szDesc then
    Log("[HyperTextHandle] tbTaskItem HandleClick ERR ?? ", szParam)
    return
  end
  nTaskId = tonumber(nTaskId)
  if not nTaskId then
    Log("[HyperTextHandle] tbTaskItem HandleClick ERR ?? ", szParam)
    return
  end
  Task:UseTaskItem(nTaskId)
end
local tbGoAndDoSomething = {}
function tbGoAndDoSomething:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbGoAndDoSomething:HandleClick(szParam, nX, nY)
  local szDesc, nMapTemplateId, nPosX, nPosY, szExtCmd, szExtParam = UnpackParam(szParam, 6)
  if not szDesc then
    Log("[HyperTextHandle] tbGoAndDoSomething HandleClick ERR ?? ", szParam)
    return
  end
  nMapTemplateId = tonumber(nMapTemplateId)
  nPosX = tonumber(nPosX)
  nPosY = tonumber(nPosY)
  GoAndDoSomething(nMapTemplateId, nPosX, nPosY, szExtCmd, szExtParam)
end
local tbNpcAndDoSomething = {}
function tbNpcAndDoSomething:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbNpcAndDoSomething:HandleClick(szParam, nX, nY)
  local szDesc, nNpcTemplateId, nMapTemplateId, szExtCmd, szExtParam = UnpackParam(szParam, 5)
  if not szDesc then
    Log("[HyperTextHandle] tbNpcAndDoSomething HandleClick ERR ?? ", szParam)
    return
  end
  nNpcTemplateId = tonumber(nNpcTemplateId)
  nMapTemplateId = tonumber(nMapTemplateId)
  local nPosX, nPosY = AutoPath:GetNpcPos(nNpcTemplateId, nMapTemplateId, true)
  GoAndDoSomething(nMapTemplateId, nPosX, nPosY, szExtCmd, szExtParam, Npc.DIALOG_DISTANCE)
end
local tbAutoFight = {}
function tbAutoFight:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbAutoFight:HandleClick(szParam, nX, nY)
  local szDesc, bAutoFight = UnpackParam(szParam, 2)
  if not szDesc then
    Log("[HyperTextHandle] tbAutoFight HandleClick ERR ?? ", szParam)
    return
  end
  local nAutoType = bAutoFight == "1" and AutoFight.OperationType.Auto or AutoFight.OperationType.Manual
  AutoFight:ChangeState(nAutoType)
end
local tbClientNpc = {}
function tbClientNpc:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbClientNpc:HandleClick(szParam)
  local szDesc, nNpcTemplateId, nMapTemplateId, nX, nY = UnpackParam(szParam, 5)
  if not szDesc then
    Log("[HyperTextHandle] tbClientNpc HandleClick ERR ?? ", szParam)
    return
  end
  nNpcTemplateId = tonumber(nNpcTemplateId)
  nMapTemplateId = tonumber(nMapTemplateId)
  nX = tonumber(nX)
  nY = tonumber(nY)
  local function fnDoSomething()
    local tbNpcList = KNpc.GetAroundNpcList(me.GetNpc(), Npc.DIALOG_DISTANCE)
    for _, pNpc in pairs(tbNpcList or {}) do
      if pNpc.nTemplateId == nNpcTemplateId then
        Operation:SimpleTap(pNpc.nId)
        return
      end
    end
  end
  AutoPath:GotoAndCall(nMapTemplateId, nX, nY, fnDoSomething, Npc.DIALOG_DISTANCE)
end
local tbClientNpcByIdx = {}
function tbClientNpcByIdx:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbClientNpcByIdx:HandleClick(szParam)
  local szDesc, nIndex = UnpackParam(szParam, 2)
  if not szDesc then
    Log("[HyperTextHandle] tbClientNpcByIdx HandleClick ERR ?? ", szParam)
    return
  end
  nIndex = tonumber(nIndex)
  local tbClientNpc = (Task.tbClientNpcInfo[nIndex] or {})[1]
  if not tbClientNpc then
    Log("[HyperTextHandle] tbClientNpcByIdx HandleClick ERR ?? tbClientNpc is nil !! ", szParam)
    return
  end
  local nNpcTemplateId = tbClientNpc.nNpcId
  local function fnDoSomething()
    local tbNpcList = KNpc.GetAroundNpcList(me.GetNpc(), Npc.DIALOG_DISTANCE)
    for _, pNpc in pairs(tbNpcList or {}) do
      if pNpc.nTemplateId == nNpcTemplateId then
        Operation:SimpleTap(pNpc.nId)
        return
      end
    end
  end
  AutoPath:GotoAndCall(tbClientNpc.nMapTemplateId, tbClientNpc.nX, tbClientNpc.nY, fnDoSomething, Npc.DIALOG_DISTANCE)
end
local tbDialog = {}
function tbDialog:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbDialog:HandleClick(szParam, nX, nY)
  local szDesc, nDialogId = UnpackParam(szParam, 2)
  if not szDesc then
    Log("[HyperTextHandle] tbDialog HandleClick ERR ?? ", szParam)
    return
  end
  nDialogId = tonumber(nDialogId)
  if not nDialogId then
    Log("[HyperTextHandle] tbDialog HandleClick ERR ?? ", szParam)
    return
  end
  Ui:TryPlaySitutionalDialog(nDialogId)
end
local tbGotoFuben = {}
function tbGotoFuben:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbGotoFuben:HandleClick(szParam, nX, nY)
  local szDesc, nSectionIdx, nSubSectionIdx, nFubenLevel = UnpackParam(szParam, 4)
  if not szDesc then
    Log("[HyperTextHandle] tbDialog HandleClick ERR ?? ", szParam)
    return
  end
  nSectionIdx = tonumber(nSectionIdx)
  nSubSectionIdx = tonumber(nSubSectionIdx)
  nFubenLevel = tonumber(nFubenLevel)
  local bRet, szMsg, nErrorCode = PersonalFuben:CheckCanCreateFuben(me, nSectionIdx, nSubSectionIdx, nFubenLevel)
  if not bRet then
    local tbParam = {
      nSectionIdx = nSectionIdx,
      nSubSectionIdx = nSubSectionIdx,
      nFubenLevel = nFubenLevel
    }
    if not PersonalFuben:ProcessErr(me, nErrorCode, tbParam) then
      me.CenterMsg(szMsg)
    end
    return
  end
  local function TryJoinFuben(tbHelperInfo)
    if not PersonalFuben:CheckCanCreateFuben(me, nSectionIdx, nSubSectionIdx, nFubenLevel) then
      return
    end
    Fuben:JoinPersonalFuben(nSectionIdx, nSubSectionIdx, nFubenLevel, tbHelperInfo, true)
  end
  if nFubenLevel == PersonalFuben.PERSONAL_LEVEL_ELITE then
    Ui:OpenWindow("HelperList", TryJoinFuben)
  else
    TryJoinFuben()
  end
end
local tbPlaySceneSound = {}
function tbPlaySceneSound:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbPlaySceneSound:HandleClick(szParam, nX, nY)
  local szDesc, nSoundId = UnpackParam(szParam, 2)
  if not szDesc then
    Log("[HyperTextHandle] tbPlaySceneSound HandleClick ERR ?? ", szParam)
    return
  end
  nSoundId = tonumber(nSoundId)
  if not nSoundId then
    Log("[HyperTextHandle] tbPlaySceneSound HandleClick ERR ?? ", szParam)
    return
  end
  Ui:PlaySceneSound(nSoundId)
end
local tbDazuo = {}
function tbDazuo:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbDazuo:HandleClick(szParam, nX, nY)
  local szDesc, bSit = UnpackParam(szParam, 2)
  if not szDesc then
    Log("[HyperTextHandle] tbDazuo HandleClick ERR ?? ", szParam)
    return
  end
  local nDoing = me.GetDoing()
  if bSit == "1" and nDoing == Npc.Doing.sit or bSit ~= "1" and nDoing ~= Npc.Doing.sit then
    return
  end
  if nDoing == Npc.Doing.sit then
    local _, nX, nY = me.GetWorldPos()
    me.GotoPosition(nX + 1, nY)
    return
  end
  if nDoing == Npc.Doing.stand or nDoing == Npc.Doing.run then
    me.UseSkill(1013, -1, me.GetNpc().nId)
  end
end
local tbCameraAnimation = {}
function tbCameraAnimation:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbCameraAnimation:HandleClick(szParam, nX, nY)
  local szDesc, nAnimationId = UnpackParam(szParam, 2)
  if not szDesc then
    Log("[HyperTextHandle] tbCameraAnimation HandleClick ERR ?? ", szParam)
    return
  end
  nAnimationId = tonumber(nAnimationId)
  if not nAnimationId then
    Log("[HyperTextHandle] tbCameraAnimation HandleClick ERR ?? ", szParam)
    return
  end
  CameraAnimation:Start(nAnimationId)
end
local tbSceneAnimation = {}
function tbSceneAnimation:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbSceneAnimation:HandleClick(szParam, nX, nY)
  local szDesc, szObjName, szAni, nSpeed, bFinishHide = UnpackParam(szParam, 4)
  if not szDesc then
    Log("[HyperTextHandle] tbSceneAnimation HandleClick ERR ?? ", szParam)
    return
  end
  nSpeed = string.gsub(nSpeed, " ", "")
  nSpeed = tonumber(nSpeed) or 1
  Ui.Effect.PlaySceneAnimation(szObjName, szAni, nSpeed, bFinishHide == "true")
end
local tbOpenUrl = {}
function tbOpenUrl:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbOpenUrl:HandleClick(szParam, nX, nY)
  local _, szUrl = string.match(szParam, "^[ \t]*([^\t,]+)[ \t]*,[ \t]*([^\t,]+)")
  if not szUrl then
    return
  end
  if IOS then
    local CoreDll = luanet.import_type("CoreInterface.CoreDll")
    CoreDll.IOSOpenUrl(szUrl)
  else
    local Application = luanet.import_type("UnityEngine.Application")
    Application.OpenURL(szUrl)
  end
end
local tbOpenInnerUrl = {}
function tbOpenInnerUrl:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbOpenInnerUrl:HandleClick(szParam)
  local _, szUrl = string.match(szParam, "^[ \t]*([^\t,]+)[ \t]*,[ \t]*([^\t,]+)")
  szUrl = string.gsub(szUrl, "%$PlayerId%$", me.dwID or 0)
  szUrl = string.gsub(szUrl, "%$SeverId%$", Sdk:GetServerId() or 0)
  szUrl = string.gsub(szUrl, "%$PlayerLevel%$", me.nLevel or 0)
  szUrl = string.gsub(szUrl, "%$Area%$", Sdk:GetAreaId())
  szUrl = string.gsub(szUrl, "%$PlayerName%$", me.szName or "")
  Sdk:OpenUrl(szUrl)
end
local tbOpenWeixinUrl = {}
function tbOpenWeixinUrl:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbOpenWeixinUrl:HandleClick(szParam)
  local _, szUrl = string.match(szParam, "^[ \t]*([^\t,]+)[ \t]*,[ \t]*([^\t,]+)")
  Sdk:OpenWeixinDeepLink(szUrl)
end
local tbDegreeCtrl = {}
function tbDegreeCtrl:WarpText(szParam)
  local szDegree = string.match(szParam, "^[ \t]?([^\t,]+)") or szParam
  local szDesc = DegreeCtrl:GetDegreeDesc(szDegree)
  local nDegree = DegreeCtrl:GetDegree(me, szDegree)
  local nMaxDegree = DegreeCtrl:GetMaxDegree(szDegree, me)
  return string.format("%s: %d/%d", szDesc or "", nDegree or 0, nMaxDegree or 0)
end
function tbDegreeCtrl:HandleClick(szParam)
  local _, szMsg = UnpackParam(szParam, 2)
  if Lib:IsEmptyStr(szMsg) then
    return
  end
  me.CenterMsg(szMsg)
end
local tbOpenNewPackageUrl = {}
function tbOpenNewPackageUrl:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbOpenNewPackageUrl:HandleClick(szParam, nX, nY)
  local _, szUrl = UnpackParam(szParam, 2)
  local tbUrl = Lib:SplitStr(szUrl, ", ")
  if IOS then
    local CoreDll = luanet.import_type("CoreInterface.CoreDll")
    CoreDll.IOSOpenUrl(tbUrl[1])
  else
    local Application = luanet.import_type("UnityEngine.Application")
    Application.OpenURL(tbUrl[2])
  end
end
local tbOpenBeautyUrl = {}
function tbOpenBeautyUrl:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbOpenBeautyUrl:HandleClick(szParam)
  local _, szUrl = string.match(szParam, "^[ \t]*([^\t,]+)[ \t]*,[ \t]*([^\t,]+)")
  local nCurCount = me.GetItemCountInAllPos(Activity.BeautyPageant.VOTE_ITEM)
  local szMyKinName = ""
  if Kin:HasKin() then
    local tbKinBaseInfo = Kin:GetBaseInfo() or {}
    szMyKinName = tbKinBaseInfo.szName or szMyKinName
  end
  local szRoleName = Lib:UrlEncode(me.szName)
  szRoleName = string.gsub(szRoleName, "%%", "%%%%")
  szMyKinName = Lib:UrlEncode(szMyKinName)
  szMyKinName = string.gsub(szMyKinName, "%%", "%%%%")
  szUrl = string.gsub(szUrl, "%$PlatId%$", Sdk:GetLoginPlatId())
  szUrl = string.gsub(szUrl, "%$Area%$", Sdk:GetAreaId())
  szUrl = string.gsub(szUrl, "%$ServerId%$", Sdk:GetServerId())
  szUrl = string.gsub(szUrl, "%$RoleId%$", me.dwID)
  szUrl = string.gsub(szUrl, "%$RoleName%$", szRoleName)
  szUrl = string.gsub(szUrl, "%$KinName%$", szMyKinName)
  szUrl = string.gsub(szUrl, "%$VoteItem%$", nCurCount)
  szUrl = string.format("%s&isLoginPC=%d", szUrl, Sdk:IsPCVersion() and 1 or 0)
  Sdk:OpenUrl(szUrl)
end
local tbViewRole = {}
function tbViewRole:WarpText(szParam)
  local szDesc = string.match(szParam, "^[ \t]?([^\t,]+)")
  return szDesc or ""
end
function tbViewRole:HandleClick(szParam)
  local _, szPlayerID = UnpackParam(szParam, 2)
  if Lib:IsEmptyStr(szPlayerID) then
    Log("[HyperTextHandle] tbViewRole HandleClick ERR ?? ", szParam)
    return
  end
  ViewRole:OpenWindow("ViewRolePanel", tonumber(szPlayerID))
end
tbClass.tbLinkClass = {
  test = tbLinkTest,
  npc = tbLinkNpc,
  pos = tbLinkPos,
  openwnd = tbOpenWindow,
  closewnd = tbCloseWindow,
  npcpath = tbNpcPath,
  clientnpc = tbClientNpc,
  clientnpcbyidx = tbClientNpcByIdx,
  taskitem = tbTaskItem,
  goanddosomething = tbGoAndDoSomething,
  npcanddosomething = tbNpcAndDoSomething,
  autofight = tbAutoFight,
  dialog = tbDialog,
  gotofuben = tbGotoFuben,
  scenesound = tbPlaySceneSound,
  dazuo = tbDazuo,
  cameraAnimation = tbCameraAnimation,
  sceneAnimation = tbSceneAnimation,
  openurl = tbOpenUrl,
  openinnerurl = tbOpenInnerUrl,
  degreectrl = tbDegreeCtrl,
  openNewPackageUrl = tbOpenNewPackageUrl,
  openWXUrl = tbOpenWeixinUrl,
  openBeautyUrl = tbOpenBeautyUrl,
  viewrole = tbViewRole
}
