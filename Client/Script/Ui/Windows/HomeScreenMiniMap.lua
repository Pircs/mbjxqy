local tbUi = Ui:CreateClass("HomeScreenMiniMap")
local tbHideMiniMapId = {
  [1003] = true,
  [1009] = true,
  [1015] = true,
  [1017] = true,
  [1018] = true,
  [1019] = true,
  [0] = true
}
function tbUi:OnOpen()
  if tbHideMiniMapId[me.nMapTemplateId] then
    return 0
  end
end
function tbUi:OnOpenEnd()
  if self.nTimer then
    Timer:Close(self.nTimer)
  end
  self.nMaxBattleNpcCount = self.nMaxBattleNpcCount or 1
  self.nMaxRobberNpcCount = self.nMaxRobberNpcCount or 1
  self.nMaxBonfireCount = self.nMaxBonfireCount or 1
  self.nMaxAttackMeCount = self.nMaxAttackMeCount or 1
  self.nLastMapId = nil
  self:ChangeMap()
  self.nTimer = Timer:Register(1, self.Active, self)
end
function tbUi:Active()
  self:ShowOthers()
  if me.nMapId ~= self.nLastMapId or not self.tbCurMapSetting then
    return true
  end
  local _, nX, nY = me.GetWorldPos()
  if nX == self.nLastX and nY == self.nLastY then
    return true
  end
  self.nLastX = nX
  self.nLastY = nY
  self:CheckCurMap()
  local szPos = string.format("（%d, %d）", math.floor(nX * Map.nShowPosScale), math.floor(nY * Map.nShowPosScale))
  self.pPanel:Label_SetText("CoordinatePoint", szPos)
  nX, nY = self:GetShowPosition(nX, nY)
  self.pPanel:ChangePosition("MapTexture", -nX, -nY, 0)
  return true
end
function tbUi:ShowOthers()
  local nNow = GetTime()
  if nNow == self.nLastShowOther then
    return
  end
  self.nLastShowOther = nNow
  if me.nMapTemplateId == Kin.Def.nKinNestMapTemplateId then
    self.pPanel:SetActive("Bonfire", true)
    local tbFirePos = Map:GetMiniMapPos("Bonfire")
    if self.nMaxBonfireCount < #tbFirePos then
      for i = self.nMaxBonfireCount + 1, #tbFirePos do
        self.pPanel:CreateWnd("Bonfire1", "Bonfire" .. i)
      end
      self.nMaxBonfireCount = #tbFirePos
    end
    for i = 1, self.nMaxBonfireCount do
      if tbFirePos[i] then
        self:ShowPos("Bonfire" .. i, tbFirePos[i][1], tbFirePos[i][2])
      else
        self.pPanel:SetActive("Bonfire" .. i, false)
      end
    end
  end
  if self.bIsBattle then
    local tbBattlePos = me.GetNpc().GetNearbyNpcByRelationChar("-enemy,+player")
    if self.nMaxBattleNpcCount < #tbBattlePos then
      for i = self.nMaxBattleNpcCount + 1, #tbBattlePos do
        self.pPanel:CreateWnd("Battle1", "Battle" .. i)
      end
      self.nMaxBattleNpcCount = #tbBattlePos
    end
    for i = 1, self.nMaxBattleNpcCount do
      if tbBattlePos[i] then
        self:ShowPos("Battle" .. i, tbBattlePos[i].nX, tbBattlePos[i].nY)
      else
        self.pPanel:SetActive("Battle" .. i, false)
      end
    end
  end
  if TeamMgr:HasTeam() then
    self.pPanel:SetActive("Team", true)
    local tbTeamMatesPos = TeamMgr:GetTeamMatesPos()
    for i = 1, TeamMgr.MAX_MEMBER_COUNT - 1 do
      if tbTeamMatesPos[i] then
        self:ShowPos("Team" .. i, tbTeamMatesPos[i][1], tbTeamMatesPos[i][2])
      else
        self.pPanel:SetActive("Team" .. i, false)
      end
    end
  else
    self.pPanel:SetActive("Team", false)
  end
  local showEscortCar = false
  local nMapId, x, y = Kin:GetEscortCarPos()
  if nMapId == me.nMapTemplateId then
    self:ShowPos("EscortCar1", x, y)
    showEscortCar = true
  end
  self.pPanel:SetActive("EscortCar", showEscortCar)
  local bShowTour = false
  local nMapId, x, y = Wedding:GetMapNpcPos()
  if nMapId and nMapId == me.nMapId then
    self:ShowPos("ChairCar1", x, y)
    bShowTour = true
  end
  self.pPanel:SetActive("ChairCar", bShowTour)
  if self.bInFightMap or self.bIsBattle then
    local tbAttackMePos = me.GetNpc().GetAttckMePlayersInfo()
    if self.nMaxAttackMeCount < #tbAttackMePos then
      for i = self.nMaxAttackMeCount + 1, #tbAttackMePos do
        self.pPanel:CreateWnd("AttackMe1", "AttackMe" .. i)
      end
      self.nMaxAttackMeCount = #tbAttackMePos
    end
    for i = 1, self.nMaxAttackMeCount do
      if tbAttackMePos[i] then
        self:ShowPos("AttackMe" .. i, tbAttackMePos[i].nX, tbAttackMePos[i].nY)
      else
        self.pPanel:SetActive("AttackMe" .. i, false)
      end
    end
  end
end
function tbUi:ChangePosition(szWndName, nX, nY)
  nX, nY = self:GetShowPosition(nX, nY)
  self.pPanel:ChangePosition(szWndName, nX, nY, 0)
end
function tbUi:GetShowPosition(nX, nY)
  nX, nY = Map:GetMapPos(nX, nY)
  nX = (nX - self.tbCurMapSetting.BeginPosX - self.tbCurMapSetting.SizeX / 2) * self.nMapScale
  nY = (nY - self.tbCurMapSetting.BeginPosY - self.tbCurMapSetting.SizeY / 2) * self.nMapScale
  return nX, nY
end
function tbUi:ShowPos(szWndName, nX, nY)
  if self.tbChildMapSetting and not Map:IsInMap(nX, nY, self.tbCurMapSetting) then
    self.pPanel:SetActive(szWndName, false)
    return
  end
  self:ChangePosition(szWndName, nX, nY)
  self.pPanel:SetActive(szWndName, true)
end
function tbUi:ChangeMap()
  self.nLastMapId = me.nMapId
  local nPlayerMapTemplateId = me.nMapTemplateId
  local tbMapSetting = Map:GetMapSetting(nPlayerMapTemplateId)
  local tbMiniMapSetting, szMiniMap, tbChildMapSetting = Map:GetMiniMapInfo(nPlayerMapTemplateId)
  self.nCameraDirAngle = tbMapSetting.CameraDirAngle
  self.tbCurMapSetting = nil
  self.tbChildMapSetting = tbChildMapSetting
  if not self.tbChildMapSetting then
    self:SwitchMiniMap(tbMiniMapSetting, szMiniMap)
  end
  self.nLastX = nil
  self.nLastY = nil
  self:CheckCurMap()
  if House.nHouseMapId and me.nMapId == House.nHouseMapId then
    self.pPanel:Label_SetText("MapName", string.format("%s的家", House.szName))
  else
    self.pPanel:Label_SetText("MapName", tbMapSetting.MapName)
  end
  self.pPanel:ChangeRotate("Rotation", self.nCameraDirAngle)
  self.pPanel:ChangeRotate("MapTexture", 0)
  self.pPanel:ChangeRotate("ShowOthers", self.nCameraDirAngle)
  local nMapScale = Map:GetMapScale(nPlayerMapTemplateId, true)
  local nMapSize = Map.MiniMapSize * nMapScale
  self.pPanel:Widget_SetSize("MapTexture", nMapSize, nMapSize)
  self.bInFightMap = Map:IsFieldFightMap(nPlayerMapTemplateId) or Fuben.WhiteTigerFuben:IsMyMap() or Map:IsBossMap(nPlayerMapTemplateId) or ImperialTomb:IsTombMap(nPlayerMapTemplateId)
  self.bIsBattle = Map:IsBattleMap(nPlayerMapTemplateId)
  self.bIsKinMap = Map:IsKinMap(nPlayerMapTemplateId)
  self.pPanel:SetActive("Battle", self.bIsBattle)
  self.pPanel:SetActive("Bonfire", self.bIsKinMap)
  self.pPanel:SetActive("AttackMe", self.bInFightMap or self.bIsBattle)
end
function tbUi:OnClose()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
tbUi.tbForbidMiniMapTouchMapId = {
  [600] = true,
  [601] = true,
  [602] = true,
  [WuLinDaHui.tbDef.tbPrepareGame.nPrepareMapTID] = true
}
function tbUi.tbOnClick:MiniMap()
  if self.tbForbidMiniMapTouchMapId[me.nMapTemplateId] then
    return
  end
  Ui:OpenWindow("MiniMap", me.nMapTemplateId)
end
function tbUi.tbOnClick:BtnWorldMap()
  if DomainBattle:GetMapLevel(me.nMapTemplateId) then
    Ui:OpenWindow("DomainMap")
    return
  end
  if self.tbForbidMiniMapTouchMapId[me.nMapTemplateId] then
    return
  end
  Ui:OpenWindow("WorldMap")
end
function tbUi:CheckCurMap()
  if not self.tbChildMapSetting then
    return
  end
  local _, nX, nY = me.GetWorldPos()
  if self.tbCurMapSetting and Map:IsInMap(nX, nY, self.tbCurMapSetting) then
    return
  end
  for _, tbInfo in ipairs(self.tbChildMapSetting) do
    if self.tbCurMapSetting ~= tbInfo.tbSetting and Map:IsInMap(nX, nY, tbInfo.tbSetting) then
      self:SwitchMiniMap(tbInfo.tbSetting, tbInfo.szMiniMap)
      return
    end
  end
end
function tbUi:SwitchMiniMap(tbMapSetting, szMiniMap)
  self.tbCurMapSetting = tbMapSetting
  local nMapScale = Map:GetMapScale(me.nMapTemplateId, true)
  self.nMapScale = Map:GetMapOrgScale(szMiniMap) * nMapScale
  local szImgPath = "UI/Textures/MiniMap/" .. szMiniMap .. ".png"
  self.pPanel:Texture_SetTexture("MapTexture", szImgPath)
end
