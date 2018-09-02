local StrengthenPanel = Ui:CreateClass("StrengthenPanel")
local SHOW_HINT_TIME = 3
local TYPE_STONE = 1
local TYPE_CRYSTAL = 2
local tbCombineLeftMenuMain = {
  {szName = "魂石", nMainKind = TYPE_STONE},
  {szName = "水晶", nMainKind = TYPE_CRYSTAL}
}
StrengthenPanel.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnTabStrengthen = function(self)
    local szOldPage = self.szType
    if szOldPage ~= "Strengthen" then
      self.tbEquips = nil
    end
    local nRet = self:OnOpen("Strengthen")
    if nRet == 0 then
      self.pPanel:Toggle_SetChecked("BtnTab" .. szOldPage, true)
      self:OnOpen(szOldPage)
    end
  end,
  BtnTabInset = function(self)
    local szOldPage = self.szType
    if szOldPage ~= "Inset" then
      self.tbEquips = nil
    end
    local nRet = self:OnOpen("Inset")
    if nRet == 0 then
      self.pPanel:Toggle_SetChecked("BtnTab" .. szOldPage, true)
      self:OnOpen(szOldPage)
    end
  end,
  BtnTabCombine = function(self)
    self:OnOpen("Combine")
  end,
  BtnCombine = function(self)
    if not self.nCombineStoneId then
      return
    end
    local nDefaultCombineCount = StoneMgr:GetCombineDefaulCount(self.nCombineStoneId)
    if nDefaultCombineCount > me.GetItemCountInAllPos(self.nCombineStoneId) then
      me.CenterMsg("所需数量不足")
      return
    end
    RemoteServer.OnCombine(self.nCombineStoneId, 1)
  end,
  BtnCombineMulti = function(self)
    if not self.nCombineStoneId then
      return
    end
    local nDefaultCombineCount = StoneMgr:GetCombineDefaulCount(self.nCombineStoneId)
    if nDefaultCombineCount > me.GetItemCountInAllPos(self.nCombineStoneId) then
      me.CenterMsg("所需数量不足")
      return
    end
    RemoteServer.OnCombine(self.nCombineStoneId, math.floor(self.nCombineHasCount / nDefaultCombineCount))
  end
}
function StrengthenPanel:OnOpen(szType, nSelectId, bNotOperEffect)
  local tbAllEquips = me.GetEquips()
  local _, nDeafaultItemId = next(tbAllEquips)
  if not nDeafaultItemId then
    me.CenterMsg("您没有装备")
    return 0
  end
  self.pPanel:SetActive("BtnTabCombine", false)
  self:CheckRedPoint()
  self.szType = szType or "Strengthen"
  self.pPanel:SetActive("strengthen", self.szType == "Strengthen")
  self.pPanel:SetActive("inset", self.szType == "Inset")
  self.pPanel:SetActive("combine", self.szType == "Combine")
  self.pPanel:SetActive("BtnCombineMulti", self.szType == "Combine")
  self.pPanel:SetActive("BtnCombine", self.szType == "Combine")
  self.pPanel:SetActive("texiaoStrength", false)
  self.pPanel:SetActive("BtnTabInset", me.nLevel >= StoneMgr.MinInsetRoleLevel)
  if nSelectId then
    self.nSelectEquipId = nSelectId
  elseif not self.nSelectEquipId then
    self.nSelectEquipId = nDeafaultItemId
  end
  if self.szType == "Strengthen" then
    if me.nLevel < Strengthen.OPEN_LEVEL then
      me.CenterMsg(Strengthen.OPEN_LEVEL .. "级才开放强化")
      return 0
    end
    self.strengthen.pPanel:SetActive("StrengthenSuccess", false)
    self.strengthen.pPanel:SetActive("StrengthenFailure", false)
    self:InitStrenEquipList()
    self:UpdateEquips()
    self:UpdateStrengthenMain(self.nSelectEquipId)
    self.strengthen.pPanel:SetActive("ModelTexture", true)
    self.strengthen.pPanel:NpcView_Open("ShowRole")
    self.strengthen.pPanel:NpcView_ShowNpc("ShowRole", 1124)
    self.strengthen.pPanel:NpcView_SetScale("ShowRole", 0.9)
    self.strengthen.pPanel:NpcView_ChangeDir("ShowRole", 180, false)
  elseif self.szType == "Inset" then
    if me.nLevel < StoneMgr.MinInsetRoleLevel then
      me.CenterMsg(StoneMgr.MinInsetRoleLevel .. "级开放镶嵌功能")
      return 0
    end
    if not self:InitInsetEquipList() then
      me.CenterMsg("当前没有可镶嵌的装备")
      return 0
    end
    if not bNotOperEffect then
      self.inset.pPanel:SetActive("xiangqianchegngong", false)
      self.inset.pPanel:SetActive("texiaobaoshixiangqian", false)
    end
    self:UpdateEquips()
    self:UpdateInsetMain(self.nSelectEquipId, true, self.nSelectStoneIndex)
  elseif self.szType == "Combine" then
    self.pPanel:SetActive("BtnTabCombine", true)
    self.tbShowedCombineLeft = Lib:CopyTB1(tbCombineLeftMenuMain)
    self:InitCombineStoneList()
    self:UpdateCombineLeft()
    self:UpdateCombineMain()
  end
end
function StrengthenPanel:OnClose()
  self.bCheckedCanDirectEnhance = nil
  self.nSelectEquipId = nil
  self.tbEquips = nil
  self.strengthen.pPanel:SetActive("ModelTexture", false)
  self.strengthen.pPanel:NpcView_Close("ShowRole")
  self.nSelectStoneIndex = nil
end
function StrengthenPanel:CheckCanDirectEnhance()
  if self.bCheckedCanDirectEnhance then
    return
  end
  self.bCheckedCanDirectEnhance = true
  local tbFindItems = me.FindItemInPlayer("DirectEnhance")
  if not next(tbFindItems) then
    return
  end
  table.sort(tbFindItems, function(a, b)
    return a.nLevel > b.nLevel
  end)
  for i, pItem in ipairs(tbFindItems) do
    local nExtLevel = KItem.GetItemExtParam(pItem.dwTemplateId, 1)
    local tbStrengthen = me.GetStrengthen()
    for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
      if nExtLevel > tbStrengthen[nEquipPos + 1] then
        return pItem
      end
    end
  end
end
function StrengthenPanel:DoStrength()
  if not self.nSelectEquipId then
    me.CenterMsg("请选择装备")
    return
  end
  local pDirEnhanceItem = self:CheckCanDirectEnhance()
  if pDirEnhanceItem then
    local szMsg = string.format("您身上有[%s][url=openwnd:%s, ItemTips, 'Item', nil, %d][-]使用后能提升至对应的强化等级，请您优先使用", "FFFE0D", pDirEnhanceItem.szName, pDirEnhanceItem.dwTemplateId)
    local function fnAgree()
      Ui:CloseWindow(self.UI_NAME)
      Item:ClientUseItem(pDirEnhanceItem.dwId)
    end
    me.MsgBox(szMsg, {
      {"确定", fnAgree},
      {"取消"}
    })
    return
  end
  local tbData = self:GetEquipInfo(self.nSelectEquipId)
  if not tbData.bUpgrade then
    me.CenterMsg(tbData.szReason)
    return
  end
  local pEquip = KItem.GetItemObj(self.nSelectEquipId)
  if not pEquip then
    return
  end
  RemoteServer.OnStrengthen(self.nSelectEquipId, tbData.nPos)
  self.strengthen.BtnStrengthen.pPanel:Button_SetEnabled("Main", false)
  Timer:Register(math.floor(Env.GAME_FPS * 1.6), function()
    self.strengthen.BtnStrengthen.pPanel:Button_SetEnabled("Main", true)
  end)
end
function StrengthenPanel:UpdateEquips()
  local function fnClick(ButtonObj)
    self.nSelectEquipId = ButtonObj.nItemId
    ButtonObj.pPanel:Toggle_SetChecked("Main", true)
    if self.szType == "Strengthen" then
      self:UpdateStrengthenMain(ButtonObj.nItemId)
    elseif self.szType == "Inset" then
      self.nSelectEquipId = ButtonObj.nItemId
      self:UpdateInsetMain(ButtonObj.nItemId, true)
    end
  end
  local function fnClickItem(itemframe)
    fnClick(itemframe.parent)
  end
  local function fnSetItem(itemObj, nIndex)
    local tbData = self.tbEquips[nIndex]
    itemObj.pPanel:Toggle_SetChecked("Main", self.nSelectEquipId == tbData.nItemId)
    itemObj.pPanel:SetActive("StoneIconGroup", self.szType == "Inset")
    itemObj.pPanel:SetActive("TxtStren", self.szType == "Strengthen")
    local szStren = string.format("强化+%d", tbData.nStrenLevel or 0)
    itemObj.pPanel:Label_SetText("TxtStren", szStren)
    local tbInset = me.GetInsetInfo(tbData.nPos)
    for i = 1, StoneMgr.INSET_COUNT_MAX do
      local nStoneTemplateId = tbInset[i]
      local szIcon, szAtlas, szExtAtlas, szExtSprite = StoneMgr:GetStoneMiniIcon(nStoneTemplateId)
      local szIconComp = "StoneIcon" .. i
      if szIcon and szIcon ~= "" then
        itemObj.pPanel:SetActive(szIconComp, true)
        itemObj.pPanel:Sprite_SetSprite(szIconComp, szIcon, szAtlas)
        if szExtAtlas and szExtAtlas ~= "" and szExtSprite and szExtSprite ~= "" then
          itemObj.pPanel:Sprite_SetSprite("StoneQuality" .. i, szExtSprite, szExtAtlas)
          itemObj.pPanel:SetActive("StoneQuality" .. i, true)
        else
          itemObj.pPanel:SetActive("StoneQuality" .. i, false)
        end
      else
        itemObj.pPanel:SetActive(szIconComp, false)
      end
    end
    itemObj.pPanel:Label_SetText("TxtName", tbData.szName)
    itemObj.pPanel:Label_SetText("TxtLevel", tbData.nEquipLevel)
    itemObj.pPanel:SetActive("UpgradeFlag", tbData.bUpgrade)
    itemObj.itemframe:SetItem(tbData.nItemId)
    itemObj.itemframe.parent = itemObj
    itemObj.itemframe.fnClick = fnClickItem
    itemObj.nItemId = tbData.nItemId
    itemObj.pPanel.OnTouchEvent = fnClick
  end
  if self.szType == "Strengthen" then
    self.strengthen.ScrollViewStrengthenEquip:Update(#self.tbEquips, fnSetItem)
  elseif self.szType == "Inset" then
    self.inset.ScrollViewInsetEquip:Update(#self.tbEquips, fnSetItem)
  end
end
function StrengthenPanel:CheckRedPoint()
  local tbAllEquips = me.GetEquips()
  local bCanStrength = false
  local bCanInset = false
  for nPos, nEquipId in pairs(tbAllEquips) do
    if bCanStrength and bCanInset then
      break
    end
    local pEquip = KItem.GetItemObj(nEquipId)
    local bUpgrade, szReason = Strengthen:CanStrengthen(me, nPos, pEquip.nLevel)
    if bUpgrade then
      bCanStrength = bUpgrade
    end
    local bUpgrade = StoneMgr:CheckInsetUpgradeFlag(nEquipId)
    if bUpgrade then
      bCanInset = bUpgrade
    end
  end
  self.pPanel:SetActive("NewInset", bCanInset)
  self.pPanel:SetActive("NewStrength", bCanStrength)
end
function StrengthenPanel:GetEquipInfo(nItemId)
  for i, v in ipairs(self.tbEquips) do
    if v.nItemId == nItemId then
      return v
    end
  end
end
function StrengthenPanel:OnOpenEnd()
  local tbTypes = {
    "Strengthen",
    "Inset",
    "Combine"
  }
  for i, v in ipairs(tbTypes) do
    self.pPanel:Toggle_SetChecked("BtnTab" .. v, self.szType == v)
  end
end
function StrengthenPanel:OnResponseStrengthen(bSuccess, nCurFightPower, nOrgFightPower)
  if self.szType == "Strengthen" then
    self.pPanel:SetActive("texiaoStrength", false)
    self.pPanel:SetActive("texiaoStrength", true)
    self.strengthen.pPanel:SetActive("StrengthenSuccess", false)
    self.strengthen.pPanel:SetActive("StrengthenFailure", false)
    do
      local fnQHTime = self.strengthen.pPanel:NpcView_PlayAnimation("ShowRole", "qh", 0.1, 1)
      Timer:Register(math.floor(Env.GAME_FPS * 0.2), function()
        Ui:PlayUISound(8014)
      end)
      Timer:Register(math.floor(Env.GAME_FPS * 1.65), function()
        Ui:PlayUISound(8014)
      end)
      if fnQHTime > 0 then
        if self.nTimerQH then
          Timer:Close(self.nTimerQH)
        end
        self.nTimerQH = Timer:Register(math.floor(Env.GAME_FPS * fnQHTime * 2 - 5), function()
          self.strengthen.pPanel:NpcView_PlayAnimation("ShowRole", "st", 0.2, 1)
          self.nTimerQH = nil
        end)
      end
      if self.nTimerStrength then
        Timer:Close(self.nTimerStrength)
        self.nTimerStrength = nil
      end
      local function fnUpdateUi()
        if self.szType ~= "Strengthen" then
          return
        end
        if self.nSelectEquipId then
          for i, v in ipairs(self.tbEquips) do
            self.tbEquips[i] = self:GetStrenEquipListItemData(v.nItemId)
          end
          self:UpdateEquips()
          self:UpdateStrengthenMain(self.nSelectEquipId)
        end
      end
      if bSuccess then
        self.nTimerStrength = Timer:Register(math.floor(Env.GAME_FPS * 2), function()
          self.strengthen.pPanel:SetActive("StrengthenSuccess", true)
          if nCurFightPower and nOrgFightPower then
            Ui:OpenWindow("FightPowerTip", nCurFightPower, nOrgFightPower)
          end
          self.nTimerStrength = nil
          fnUpdateUi()
        end)
      else
        self.nTimerStrength = Timer:Register(math.floor(Env.GAME_FPS * 2), function()
          self.strengthen.pPanel:SetActive("StrengthenFailure", true)
          self.strengthen.pPanel:Tween_AlphaWithStart("StrengthenFailure", 1, 0, 1)
          self.nTimerStrength = nil
          fnUpdateUi()
        end)
      end
    end
  end
  self:CheckRedPoint()
end
function StrengthenPanel:OnResponseInset(bInseted, nInsetPos)
  for i, v in ipairs(self.tbEquips) do
    self.tbEquips[i] = self:GetInsetEquipListItemData(v.nItemId)
  end
  self:UpdateEquips()
  self:UpdateInsetMain(self.nSelectEquipId, true, nInsetPos)
  if bInseted and nInsetPos then
    local tbTarPos = self.inset["EquipStone" .. nInsetPos].pPanel:GetWorldPosition("StoneItem")
    tbTarPos = self.pPanel:GetRelativePosition("inset", tbTarPos.x, tbTarPos.y)
    self.inset.pPanel:ChangePosition("texiaobaoshixiangqian", tbTarPos.x, tbTarPos.y)
    self.inset.pPanel:SetActive("texiaobaoshixiangqian", false)
    self.inset.pPanel:SetActive("texiaobaoshixiangqian", true)
  end
  self:CheckRedPoint()
end
function StrengthenPanel:OnResponseCombine()
  self:UpdateCombineMain(self.nCombineStoneId)
end
function StrengthenPanel:OnSyncItem()
  self:OnOpen(self.szType, nil, true)
end
function StrengthenPanel:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_STRENGTHEN_RESULT,
      self.OnResponseStrengthen
    },
    {
      UiNotify.emNOTIFY_INSET_RESULT,
      self.OnResponseInset
    },
    {
      UiNotify.emNOTIFY_COMBINE_RESULT,
      self.OnResponseCombine
    },
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.OnSyncItem
    },
    {
      UiNotify.emNOTIFY_DEL_ITEM,
      self.OnSyncItem
    }
  }
  return tbRegEvent
end
function StrengthenPanel:GetInsetEquipListItemData(nEquipId)
  local pItem = KItem.GetItemObj(nEquipId)
  if not pItem then
    return
  end
  if pItem.nHoleCount and pItem.nHoleCount <= 0 then
    return
  end
  local nPos = pItem.nEquipPos
  local bUpgrade = StoneMgr:CheckInsetUpgradeFlag(nEquipId)
  local szName = pItem.GetItemShowInfo(me.nFaction)
  local nFightPower = pItem.nFightPower + Strengthen:GetStrenFightPower(me, nPos) + StoneMgr:GetInsetFightPower(me, nPos)
  return {
    nPos = nPos,
    nItemType = pItem.nItemType,
    szName = szName,
    nTemplateId = pItem.dwTemplateId,
    nEquipLevel = pItem.nLevel,
    bUpgrade = bUpgrade,
    nItemId = pItem.dwId,
    nFightPower = nFightPower
  }
end
function StrengthenPanel:InitInsetEquipList()
  if self.tbEquips then
    local tbOldEqips = self.tbEquips
    self.tbEquips = {}
    for i, v in ipairs(tbOldEqips) do
      local tbData = self:GetInsetEquipListItemData(v.nItemId)
      if tbData then
        table.insert(self.tbEquips, tbData)
      end
    end
    if not next(self.tbEquips) then
      self.tbEquips = nil
      self.nSelectEquipId = nil
    end
  end
  if not self.tbEquips then
    if me.nLevel < StoneMgr.MinInsetRoleLevel then
      return false
    end
    local tbAllEquips = me.GetEquips()
    self.tbEquips = {}
    for nPos, nEquipId in pairs(tbAllEquips) do
      local tbData = self:GetInsetEquipListItemData(nEquipId)
      if tbData then
        table.insert(self.tbEquips, tbData)
      end
    end
    if not next(self.tbEquips) then
      self.tbEquips = nil
      return false
    end
    if not self.nSelectEquipId then
      self.nSelectEquipId = self.tbEquips[1].nItemId
    end
    table.sort(self.tbEquips, function(item1, item2)
      if self.nSelectEquipId == item1.nItemId then
        return true
      elseif self.nSelectEquipId == item2.nItemId then
        return false
      else
        return item1.nPos < item2.nPos
      end
    end)
  end
  return true
end
local fnClickQuicklyCombine = function(self, nEquipId, nTemplateId, nEquipPos, nInsetPos)
  local function fnRet(ButtonObj)
    local function OnOk()
      RemoteServer.OnQuicklyCombine(nEquipId, nInsetPos)
    end
    local nDefaultCombineCount = StoneMgr:GetCombineDefaulCount(nTemplateId)
    local tbTotalStone, nCost = StoneMgr:GetCombineStoneNeed(nTemplateId, nDefaultCombineCount, me, true, nEquipPos)
    local tbItemBoxStones = {}
    local tbInsetStones = {}
    for i, v in ipairs(tbTotalStone) do
      local nLastItemId, nLastItemNum, nOrgInsetPos = unpack(v)
      if nOrgInsetPos then
        tbInsetStones[nLastItemId] = (tbInsetStones[nLastItemId] or 0) + nLastItemNum
      else
        tbItemBoxStones[nLastItemId] = (tbItemBoxStones[nLastItemId] or 0) + nLastItemNum
      end
    end
    local szStone = ""
    for nStoneId, nNum in pairs(tbItemBoxStones) do
      local tbBaseInfo = KItem.GetItemBaseProp(nStoneId)
      if szStone ~= "" then
        szStone = szStone .. "、"
      else
        szStone = "背包里的"
      end
      szStone = string.format("%s[FFFE0D]%d[-]个[FFFE0D]%s[-]", szStone, nNum, tbBaseInfo.szName)
    end
    local szStone2 = ""
    for nStoneId, nNum in pairs(tbInsetStones) do
      local tbBaseInfo = KItem.GetItemBaseProp(nStoneId)
      if szStone2 ~= "" then
        szStone2 = szStone2 .. "、"
      else
        szStone2 = "已镶嵌的"
      end
      szStone2 = string.format("%s[FFFE0D]%d[-]个[FFFE0D]%s[-]", szStone2, nNum, tbBaseInfo.szName)
    end
    local szConnect = ""
    if szStone ~= "" and szStone2 ~= "" then
      szConnect = "，"
    end
    szStone = szStone .. szConnect .. szStone2
    local tbBaseInfo = KItem.GetItemBaseProp(StoneMgr:GetNextLevelStone(nTemplateId))
    Ui:OpenWindow("MessageBox", string.format("将%s合成1个[FFFE0D]%s[-]，花费 [FFFE0D]%d银两[-]", szStone, tbBaseInfo.szName, nCost), {
      {OnOk},
      {}
    })
  end
  return fnRet
end
function StrengthenPanel:SelectStoneIdex(nEquipId, nInsetPos)
  for i = 1, StoneMgr.INSET_COUNT_MAX do
    local stonePanel = self.inset["EquipStone" .. i]
    stonePanel.pPanel:Toggle_SetChecked("Bg", nInsetPos == i)
  end
  self.nSelectStoneIndex = nInsetPos
  self:SelectInsetPos(nEquipId, nInsetPos)
end
function StrengthenPanel:SelectInsetPos(nEquipId, nInsetPos)
  if not nEquipId then
    self.inset.ScrollViewInSetStone:Update(0)
    return
  end
  local tbStones = StoneMgr:GetCanInsetStoneIds(nEquipId)
  table.sort(tbStones, function(a, b)
    return a.nLevel > b.nLevel
  end)
  local function fnClickItem(itemObj)
    local nTemplate = itemObj.nTemplate
    local bRet, szInfo, tbCombineCount, nCombineCost, nNextTemplateId = StoneMgr:CanInset(nEquipId, nTemplate, me, nInsetPos)
    if not bRet then
      me.CenterMsg(szInfo or "无法镶嵌")
      return
    end
    local pEquip = KItem.GetItemObj(nEquipId)
    local tbInset = me.GetInsetInfo(pEquip.nEquipPos)
    local nOrgTemplate = tbInset[nInsetPos]
    local function OnOk()
      RemoteServer.OnInset(nEquipId, nTemplate, nInsetPos)
    end
    local tbBaseInfoNew = KItem.GetItemBaseProp(nTemplate)
    if nOrgTemplate and nOrgTemplate ~= 0 then
      local tbBaseInfoOrg = KItem.GetItemBaseProp(nOrgTemplate)
      local szMsg = string.format("将[FFFE0D]%s[-]替换为[FFFE0D]%s[-]，花费 [FFFE0D]%d银两[-]", tbBaseInfoOrg.szName, tbBaseInfoNew.szName, StoneMgr:GetRemoveInsetCost(nOrgTemplate))
      if tbCombineCount and nCombineCost and nNextTemplateId then
        local szStone = ""
        for i, v in ipairs(tbCombineCount) do
          local tbBaseInfo = KItem.GetItemBaseProp(v[1])
          if szStone ~= "" then
            szStone = szStone .. "、"
          end
          szStone = string.format("%s[FFFE0D]%d[-]个[FFFE0D]%s[-]", szStone, v[2], tbBaseInfo.szName)
        end
        local tbNextItemInfo = KItem.GetItemBaseProp(nNextTemplateId)
        local nCost = nCombineCost + StoneMgr:GetRemoveInsetCost(nOrgTemplate)
        szMsg = string.format("将%s合成1个[FFFE0D]%s[-]，并替换[FFFE0D]%s[-]，共花费 [FFFE0D]%d银两[-]", szStone, tbNextItemInfo.szName, tbBaseInfoOrg.szName, nCost)
      end
      Ui:OpenWindow("MessageBox", szMsg, {
        {OnOk},
        {}
      })
    elseif tbBaseInfoNew.nLevel >= 4 then
      Ui:OpenWindow("MessageBox", string.format("你确定要在一个空位中镶嵌一个[FFFE0D]%s[-]吗？", tbBaseInfoNew.szName), {
        {OnOk},
        {}
      })
    else
      OnOk()
    end
  end
  local function fnSetItem(itemObj, index)
    local v = tbStones[index]
    local nTemplate = v.nTemplateId
    local szDesc1, szDesc2 = StoneMgr:GetStoneAttrib(nTemplate)
    local tbBaseInfo = KItem.GetItemBaseProp(nTemplate)
    local nQuality = tbBaseInfo.nQuality
    local szColor = Item:GetQualityColor(nQuality)
    itemObj.pPanel:Label_SetText("TxtAttribName1", szDesc1 or "")
    itemObj.pPanel:Label_SetText("TxtAttribName2", szDesc2 or "")
    itemObj.pPanel:Label_SetText("TxtName", tbBaseInfo.szName)
    itemObj.pPanel:Label_SetColorByName("TxtAttribName1", szColor)
    itemObj.pPanel:Label_SetColorByName("TxtAttribName2", szColor)
    itemObj.pPanel:Label_SetColorByName("TxtName", szColor)
    itemObj.nTemplate = nTemplate
    itemObj.itemframe:SetItemByTemplate(nTemplate, v.nCount)
    itemObj.itemframe.fnClick = fnClickItem
    itemObj.pPanel.OnTouchEvent = fnClickItem
  end
  self.inset.ScrollViewInSetStone:Update(tbStones, fnSetItem)
end
function StrengthenPanel:UpdateInsetMain(nEquipId, bAutoSelectEmpty, nDefaultIndex)
  if not nEquipId then
    return
  end
  local pEquip = KItem.GetItemObj(nEquipId)
  if not pEquip then
    return
  end
  local nHoleCount = pEquip.nHoleCount
  local tbInset = me.GetInsetInfo(pEquip.nEquipPos)
  local _, szFrameColor = Item:GetQualityColor(pEquip.nInsetLevel)
  local nEmptyIndex
  for i = 1, StoneMgr.INSET_COUNT_MAX do
    local nTemplateId = tbInset[i]
    local stonePanel = self.inset["EquipStone" .. i]
    stonePanel.pPanel:SetActive("BtnGet", false)
    stonePanel.pPanel:Sprite_SetSprite("Color", szFrameColor)
    if nTemplateId ~= 0 then
      stonePanel.pPanel:SetActive("StoneItem", true)
      local szName, nIcon, nView, nQuality = KItem.GetItemShowInfo(nTemplateId, me.nFaction)
      local szIconAtlas, szIconSprite, szExtAtlas, szExtSprite = Item:GetIcon(nIcon)
      if szExtAtlas and szExtAtlas ~= "" and szExtSprite and szExtSprite ~= "" then
        stonePanel.pPanel:Sprite_SetSprite("Fragment", szExtSprite, szExtAtlas)
        stonePanel.pPanel:SetActive("Fragment", true)
      else
        stonePanel.pPanel:SetActive("Fragment", false)
      end
      stonePanel.pPanel:SetActive("ItemLayer", true)
      stonePanel.pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas)
      stonePanel.pPanel:SetActive("TxtStoneAttrib_a", true)
      stonePanel.pPanel:SetActive("TxtStoneAttrib_b", true)
      stonePanel.pPanel:SetActive("BtnUnload", false)
      stonePanel.pPanel:SetActive("TxtStoneAttrib_Name", true)
      stonePanel.pPanel:SetActive("TxtGuide", false)
      stonePanel.pPanel:Toggle_SetEnale("Bg", true)
      stonePanel.pPanel:Button_SetEnabled("Bg", true)
      local szDesc1, szDesc2 = StoneMgr:GetStoneAttrib(nTemplateId)
      local szColor = Item:GetQualityColor(nQuality)
      stonePanel.pPanel:Label_SetText("TxtStoneAttrib_a", szDesc1 or "")
      stonePanel.pPanel:Label_SetText("TxtStoneAttrib_b", szDesc2 or "")
      stonePanel.pPanel:Label_SetText("TxtStoneAttrib_Name", szName)
      stonePanel.pPanel:Label_SetColorByName("TxtStoneAttrib_a", szColor)
      stonePanel.pPanel:Label_SetColorByName("TxtStoneAttrib_b", szColor)
      stonePanel.pPanel:Label_SetColorByName("TxtStoneAttrib_Name", szColor)
      function stonePanel.Bg.pPanel.OnTouchEvent()
        self:SelectInsetPos(nEquipId, i)
      end
      local bQuicklyInset = StoneMgr:CanQuiklyCombine(nTemplateId, pEquip, i)
      stonePanel.pPanel:SetActive("UpgradeTips", bQuicklyInset)
      if bQuicklyInset then
        stonePanel.ItemLayer.pPanel.OnTouchEvent = fnClickQuicklyCombine(self, nEquipId, nTemplateId, pEquip.nEquipPos, i)
      else
        stonePanel.ItemLayer.pPanel.OnTouchEvent = stonePanel.Bg.pPanel.OnTouchEvent
      end
    else
      stonePanel.pPanel:SetActive("TxtStoneAttrib_a", false)
      stonePanel.pPanel:SetActive("TxtStoneAttrib_b", false)
      stonePanel.pPanel:SetActive("UpgradeTips", false)
      stonePanel.pPanel:SetActive("BtnUnload", false)
      stonePanel.pPanel:SetActive("TxtStoneAttrib_Name", false)
      if i <= nHoleCount then
        nEmptyIndex = nEmptyIndex or i
        stonePanel.pPanel:SetActive("StoneItem", true)
        stonePanel.pPanel:SetActive("ItemLayer", false)
        stonePanel.pPanel:SetActive("Fragment", false)
        stonePanel.pPanel:SetActive("TxtGuide", true)
        stonePanel.pPanel:Toggle_SetEnale("Bg", true)
        stonePanel.pPanel:Button_SetEnabled("Bg", true)
        function stonePanel.Bg.pPanel.OnTouchEvent()
          self:SelectInsetPos(nEquipId, i)
        end
        stonePanel.ItemLayer.pPanel.OnTouchEvent = stonePanel.Bg.pPanel.OnTouchEvent
      else
        stonePanel.pPanel:SetActive("TxtGuide", false)
        stonePanel.pPanel:SetActive("StoneItem", false)
        stonePanel.pPanel:Toggle_SetEnale("Bg", false)
        stonePanel.pPanel:Button_SetEnabled("Bg", false)
      end
    end
  end
  if bAutoSelectEmpty then
    if nDefaultIndex and not nEmptyIndex then
      nEmptyIndex = nDefaultIndex
    end
    self:SelectStoneIdex(nEquipId, nEmptyIndex or 1)
  end
end
function StrengthenPanel:GetStrenEquipListItemData(nEquipId)
  local pItem = KItem.GetItemObj(nEquipId)
  if not pItem then
    return
  end
  local nPos = pItem.nEquipPos
  local bUpgrade, szReason, _, nCombineCost = Strengthen:CanStrengthen(me, nPos, pItem.nLevel)
  local szName = pItem.GetItemShowInfo(me.nFaction)
  local nFightPower = pItem.nFightPower + Strengthen:GetStrenFightPower(me, nPos) + StoneMgr:GetInsetFightPower(me, nPos)
  return {
    nPos = nPos,
    nItemType = pItem.nItemType,
    szName = szName,
    nTemplateId = pItem.dwTemplateId,
    nEquipLevel = pItem.nLevel,
    nFightPower = nFightPower,
    bUpgrade = bUpgrade,
    szReason = szReason,
    nItemId = pItem.dwId,
    nStrenLevel = Strengthen:GetStrengthenLevel(me, nPos),
    nCombineCost = nCombineCost
  }
end
function StrengthenPanel:InitStrenEquipList()
  if self.tbEquips then
    local tbOldEqips = self.tbEquips
    self.tbEquips = {}
    for i, v in ipairs(tbOldEqips) do
      local tbData = self:GetStrenEquipListItemData(v.nItemId)
      if tbData then
        table.insert(self.tbEquips, tbData)
      end
    end
    if not next(self.tbEquips) then
      self.tbEquips = nil
      self.nSelectEquipId = nil
    end
  end
  if not self.tbEquips then
    local tbAllEquips = me.GetEquips()
    self.tbEquips = {}
    for nPos, nEquipId in pairs(tbAllEquips) do
      local tbData = self:GetStrenEquipListItemData(nEquipId)
      if tbData then
        table.insert(self.tbEquips, tbData)
      end
    end
    if not self.nSelectEquipId and next(self.tbEquips) then
      self.nSelectEquipId = self.tbEquips[1].nItemId
    end
    table.sort(self.tbEquips, function(item1, item2)
      if self.nSelectEquipId == item1.nItemId then
        return true
      elseif self.nSelectEquipId == item2.nItemId then
        return false
      else
        return item1.nPos < item2.nPos
      end
    end)
  end
end
function StrengthenPanel:UpdateStrengthenMain(nItemId)
  if not nItemId then
    return
  end
  local tbData = self:GetEquipInfo(nItemId)
  if not tbData then
    return
  end
  local curPanel = self.strengthen
  curPanel.EquipItem:SetItem(nItemId)
  curPanel.pPanel:Label_SetText("TxtName", tbData.szName)
  curPanel.pPanel:Label_SetText("TxtEnhLevel", "+" .. tbData.nStrenLevel)
  curPanel.pPanel:Label_SetText("Equipmenttype", Item.EQUIPPOS_NAME[tbData.nPos])
  curPanel.pPanel:Label_SetText("TxtCurStrenLevel", "强化+" .. tbData.nStrenLevel)
  if tbData.nStrenLevel == Strengthen.STREN_LEVEL_MAX then
    curPanel.pPanel:Label_SetText("TxtNextStrenLevel", "-")
  else
    curPanel.pPanel:Label_SetText("TxtNextStrenLevel", "强化+" .. tbData.nStrenLevel + 1)
  end
  local tbStrenDesc = Strengthen:GetEquipStrengthenInfo(me, tbData.nTemplateId, tbData.nPos)
  local nCurFightPower = Strengthen:GetStrenFightPower(me, tbData.nPos, tbData.nStrenLevel)
  local nNextFightPower = Strengthen:GetStrenFightPower(me, tbData.nPos, tbData.nStrenLevel + 1)
  curPanel.pPanel:Label_SetText("TxtEquipFightCur", string.format("战力 %d", nCurFightPower))
  curPanel.pPanel:Label_SetText("TxtEquipFightNext", string.format("战力 %d", nNextFightPower))
  curPanel.pPanel:Label_SetText("TxtExtent3", tostring(nNextFightPower - nCurFightPower))
  for i = 1, 2 do
    local tbAttrib = tbStrenDesc[i]
    if tbAttrib then
      local tbCur, tbNext = tbAttrib.tbCur, tbAttrib.tbNext
      curPanel.pPanel:SetActive("AttribWidget" .. i, true)
      curPanel.pPanel:Label_SetText("TxtProbName" .. i, tbCur.szName)
      curPanel.pPanel:Label_SetText("TxtProbCur" .. i, tbCur.szValue)
      if tbNext.szValue and tbNext.szValue ~= "" then
        curPanel.pPanel:Label_SetText("TxtProbNext" .. i, tbNext.szValue)
        local nExtent = tonumber(tbNext.szValue) - tonumber(tbCur.szValue or 0)
        curPanel.pPanel:Label_SetText("TxtExtent" .. i, nExtent)
      else
        curPanel.pPanel:Label_SetText("TxtProbNext" .. i, "-")
        curPanel.pPanel:Label_SetText("TxtExtent" .. i, "-")
      end
    else
      curPanel.pPanel:SetActive("AttribWidget" .. i, false)
    end
  end
  curPanel.CostItem.fnClick = curPanel.CostItem.DefaultClick
  local tbSetting = Strengthen:GetStrenSetting(tbData.nStrenLevel)
  local szBtnText, nConsumeTemplateId, nConsumeCount, nConsumeMoney, nMoneyCount, szCostname
  local szPrefix = Strengthen.tbPosPrefixName[tbData.nPos]
  if Strengthen:IsNeedBreakThrough(me, tbData.nPos) then
    szBtnText = "突    破"
    nConsumeTemplateId = KItem.GetTemplateByKind(tbSetting.BreakItem)
    nConsumeCount = tbSetting["BreakCount" .. szPrefix]
    nMoneyCount = 0
    szCostname = "突破需求"
    curPanel.pPanel:SetActive("TxtSuccessProb", false)
    curPanel.pPanel:SetActive("TxtSuccessTip", false)
    curPanel.pPanel:SetActive("TxtSuccessProbAdd", false)
    curPanel.pPanel:SetActive("strengthendata", false)
    curPanel.pPanel:SetActive("TxtBreakThrough", true)
    curPanel.pPanel:SetActive("MoneyIcon", false)
    curPanel.pPanel:SetActive("strengthenTip", false)
    if tbData.nEquipLevel < tbSetting.LevelMin then
      curPanel.pPanel:Label_SetText("TxtBreakThrough", "当前阶数的装备不能再继续强化，需要更换到下一阶装备才可继续强化")
      curPanel.pPanel:SetActive("ConsumptionStren", false)
      curPanel.pPanel:SetActive("BtnStrengthen", false)
    else
      curPanel.pPanel:SetActive("ConsumptionStren", true)
      curPanel.pPanel:SetActive("BtnStrengthen", true)
      curPanel.pPanel:Label_SetText("TxtBreakThrough", "装备已到达强化的瓶颈，需要进行突破，才可继续强化")
    end
  else
    szBtnText = "强    化"
    curPanel.pPanel:SetActive("ConsumptionStren", true)
    curPanel.pPanel:SetActive("BtnStrengthen", true)
    curPanel.pPanel:SetActive("strengthendata", true)
    curPanel.pPanel:SetActive("TxtBreakThrough", false)
    nConsumeTemplateId = KItem.GetTemplateByKind(tbSetting.ConsumeItem)
    nConsumeCount = tbSetting["ConsumeCount" .. szPrefix]
    nMoneyCount = Strengthen:GetStrengthenCost(tbData.nStrenLevel, tbData.nPos)
    szCostname = "强化消耗"
    curPanel.pPanel:SetActive("TxtSuccessProb", true)
    curPanel.pPanel:SetActive("TxtSuccessTip", true)
    curPanel.pPanel:Label_SetText("TxtSuccessTip", string.format("（失败后，增加%d%%的成功率）", tbData.nStrenLevel >= Strengthen.USE_PROB2_ENHANCE_LEVEL and math.floor(Strengthen.FAIL_ADD_PROB2 / 10) or math.floor(Strengthen.FAIL_ADD_PROB / 10)))
    curPanel.pPanel:SetActive("TxtSuccessProbAdd", false)
    local nProbility = Strengthen:GetStrengthenProb(tbSetting.Probility, Strengthen:GetStrengthenFailTimes(me, tbData.nPos), tbData.nStrenLevel)
    curPanel.pPanel:Label_SetText("TxtSuccessProb", string.format("成功率:%d%%", tbSetting.Probility / 10))
    if nProbility > tbSetting.Probility then
      curPanel.pPanel:Label_SetText("TxtSuccessProbAdd", string.format("+%d%%", (nProbility - tbSetting.Probility) / 10))
      curPanel.pPanel:SetActive("TxtSuccessProbAdd", true)
    end
    curPanel.pPanel:SetActive("MoneyIcon", true)
    local szIcon, szAtlas = Shop:GetMoneyIcon("Coin")
    curPanel.pPanel:Sprite_SetSprite("MoneyIcon", szIcon, szAtlas)
    curPanel.pPanel:SetActive("strengthenTip", true)
  end
  curPanel.pPanel:Label_SetText("titleCostName", szCostname)
  curPanel.BtnStrengthen.pPanel:Button_SetText("Main", szBtnText)
  curPanel.CostItem:SetItemByTemplate(nConsumeTemplateId, nil, me.nFaction)
  if nMoneyCount > 0 then
    curPanel.pPanel:SetActive("TxtMoney", true)
    curPanel.pPanel:Label_SetText("TxtMoney", nMoneyCount)
    curPanel.pPanel:Label_SetColorByName("TxtMoney", nMoneyCount <= me.GetMoney("Coin") and "White" or "Red")
  else
    curPanel.pPanel:SetActive("TxtMoney", false)
  end
  local tbBaseInfoConsume = KItem.GetItemBaseProp(nConsumeTemplateId)
  curPanel.pPanel:Label_SetText("ItemName", tbBaseInfoConsume.szName)
  local nExistCount = StoneMgr:GetHasCurStoneId(me, nConsumeTemplateId)
  local szConsume = string.format("%d/%d", nExistCount, nConsumeCount)
  if nConsumeCount > nExistCount then
    curPanel.pPanel:Label_SetColorByName("TxtConsume", "Red")
  else
    curPanel.pPanel:Label_SetColorByName("TxtConsume", "White")
  end
  if tbData.nCombineCost and 0 < tbData.nCombineCost then
    curPanel.pPanel:SetActive("CrystalSynthesis", true)
    curPanel.pPanel:Label_SetText("TxtMoney2", tbData.nCombineCost)
    curPanel.pPanel:Label_SetColorByName("TxtMoney2", nMoneyCount + tbData.nCombineCost <= me.GetMoney("Coin") and "White" or "Red")
  else
    curPanel.pPanel:SetActive("CrystalSynthesis", false)
  end
  curPanel.pPanel:Label_SetText("TxtConsume", szConsume)
  function curPanel.BtnStrengthen.pPanel.OnTouchEvent(...)
    self:DoStrength()
  end
  curPanel.BtnGet.pPanel:SetActive("Main", true)
  function curPanel.BtnGet.pPanel.OnTouchEvent(...)
    if not Shop:AutoChooseItem(nConsumeTemplateId) then
      local nPreId = StoneMgr:GetPreStoneId(nConsumeTemplateId)
      if nPreId and not Shop:AutoChooseItem(nPreId) then
        nPreId = StoneMgr:GetPreStoneId(nPreId)
        if nPreId then
          Shop:AutoChooseItem(nPreId)
        end
      end
    end
  end
end
function StrengthenPanel:InitCombineStoneList()
  local tbAllStones = StoneMgr:GetAllStoneInBag(me, true)
  self.tbStones = {}
  self.tbComebineKindsData = {
    [TYPE_STONE] = {},
    [TYPE_CRYSTAL] = {}
  }
  for nTemplateId, nCount in pairs(tbAllStones) do
    local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)
    local bCrystal = StoneMgr:IsCrystal(nTemplateId)
    local nDefaultCombineCount = bCrystal and StoneMgr.COMBINE_CRYSTAL_COUNT or StoneMgr.COMBINE_COUNT
    local bUpgrade = nCount >= nDefaultCombineCount and StoneMgr:GetNextLevelStone(nTemplateId) ~= 0
    local bDebris = StoneMgr:IsStoneDebris(nTemplateId)
    local tbData = {
      nTemplateId = nTemplateId,
      szName = tbBaseInfo.szName,
      nLevel = tbBaseInfo.nLevel,
      bUpgrade = bUpgrade,
      nCount = nCount,
      bCrystal = bCrystal,
      bDebris = bDebris
    }
    table.insert(self.tbStones, tbData)
  end
  local tbMysStones = me.FindItemInBag("MysteryStone")
  for i, pItem in ipairs(tbMysStones) do
    table.insert(self.tbStones, {
      nTemplateId = pItem.dwTemplateId,
      szName = pItem.szName,
      nLevel = pItem.nLevel,
      nCount = pItem.nCount,
      bCrystal = true
    })
  end
  table.sort(self.tbStones, function(item1, item2)
    if item1.bUpgrade ~= item2.bUpgrade then
      return item1.bUpgrade
    end
    if item1.bDebris ~= item1.bDebris then
      return item2.bDebris
    end
    if item1.bCrystal ~= item2.bCrystal then
      return item2.bCrystal
    end
    if item1.bUpgrade ~= item2.bUpgrade then
      return item1.bUpgrade
    end
    return item1.nLevel > item2.nLevel
  end)
  for i, v in ipairs(self.tbStones) do
    if v.bCrystal then
      table.insert(self.tbComebineKindsData[TYPE_CRYSTAL], v)
    else
      table.insert(self.tbComebineKindsData[TYPE_STONE], v)
    end
  end
  table.sort(self.tbComebineKindsData[TYPE_CRYSTAL], function(item1, item2)
    return item1.nLevel < item2.nLevel
  end)
  table.sort(self.tbComebineKindsData[TYPE_STONE], function(item1, item2)
    return item1.nLevel < item2.nLevel
  end)
end
function StrengthenPanel:UpdateCombineLeft()
  local function fnSetSubItem()
    local tbView = {}
    for i, v in ipairs(tbCombineLeftMenuMain) do
      table.insert(tbView, v)
      if self.nCombineLeftSelKind == v.nMainKind then
        for i2, v2 in ipairs(self.tbComebineKindsData[v.nMainKind]) do
          table.insert(tbView, v2)
        end
      end
    end
    self.tbShowedCombineLeft = tbView
  end
  if self.nCombineLeftSelKind and #self.tbShowedCombineLeft == #tbCombineLeftMenuMain then
    fnSetSubItem()
  end
  local function fnClickClass(buttonObj)
    local tbData = buttonObj.tbData
    if tbData.nMainKind then
      if tbData.nMainKind == self.nCombineLeftSelKind then
        self.tbShowedCombineLeft = Lib:CopyTB1(tbCombineLeftMenuMain)
        self.nCombineLeftSelKind = nil
      else
        self.nCombineLeftSelKind = tbData.nMainKind
        fnSetSubItem()
        self.combine.ScrollViewCombineStone.pPanel:ScrollViewGoTop()
      end
      self:UpdateCombineHegiht()
      self:UpdateCombineLeft()
      return
    else
      self:UpdateCombineMain(tbData.nTemplateId)
    end
  end
  local function fnSetItem(itemObj, index)
    local tbData = self.tbShowedCombineLeft[index]
    if tbData.nMainKind then
      itemObj.pPanel:SetActive("BaseClass", true)
      itemObj.pPanel:SetActive("SubClass", false)
      local tbNextData = self.tbShowedCombineLeft[index + 1]
      if tbNextData and not tbNextData.nMainKind then
        itemObj.BaseClass.pPanel:SetActive("BtnDownS", false)
        itemObj.BaseClass.pPanel:SetActive("Checked", true)
        itemObj.BaseClass.pPanel:Button_SetSprite("Main", "BtnListMainPress", 1)
      else
        itemObj.BaseClass.pPanel:SetActive("BtnDownS", true)
        itemObj.BaseClass.pPanel:SetActive("Checked", false)
        itemObj.BaseClass.pPanel:Button_SetSprite("Main", "BtnListMainNormal", 1)
      end
      itemObj.BaseClass.pPanel:Label_SetText("LabelLight", tbData.szName)
      itemObj.BaseClass.pPanel:Label_SetText("LabelDark", tbData.szName)
      itemObj.BaseClass.tbData = tbData
      itemObj.BaseClass.pPanel.OnTouchEvent = fnClickClass
    else
      itemObj.pPanel:SetActive("BaseClass", false)
      itemObj.pPanel:SetActive("SubClass", true)
      itemObj.SubClass.pPanel:Label_SetText("Label", string.format("%s(%s)", tbData.szName, Lib:StrFillR(tbData.nCount, 2, " ")))
      itemObj.SubClass.pPanel:Toggle_SetChecked("Main", self.nCombineStoneId == tbData.nTemplateId)
      itemObj.SubClass.tbData = tbData
      itemObj.SubClass.pPanel.OnTouchEvent = fnClickClass
    end
  end
  self.combine.ScrollViewCombineStone:Update(self.tbShowedCombineLeft, fnSetItem)
end
function StrengthenPanel:UpdateCombineHegiht()
  local tbHeight = {}
  for i, v in ipairs(self.tbShowedCombineLeft) do
    local nHeight = v.nMainKind and 76 or 60
    table.insert(tbHeight, nHeight)
  end
  self.combine.ScrollViewCombineStone:UpdateItemHeight(tbHeight)
end
function StrengthenPanel:UpdateCombineMain(nStoneTemplateId)
  if not nStoneTemplateId then
    self.combine.ItemCombineSrc:Clear()
    self.combine.ItemCombineTar:Clear()
    self.combine.pPanel:Label_SetText("TxtCombineCount", "")
    self.combine.pPanel:Label_SetText("TxtCombineCost", "")
    return
  end
  self.nCombineStoneId = nStoneTemplateId
  local nNextTemplateId = StoneMgr:GetNextLevelStone(nStoneTemplateId)
  if nNextTemplateId == 0 then
    self.combine.ItemCombineTar.fnClick = nil
    self.combine.pPanel:SetActive("ItemCombineTar", false)
  else
    self.combine.pPanel:SetActive("ItemCombineTar", true)
    self.combine.ItemCombineTar:SetItemByTemplate(nNextTemplateId)
    self.combine.ItemCombineTar.fnClick = self.combine.ItemCombineTar.DefaultClick
  end
  local nHasCount = me.GetItemCountInAllPos(nStoneTemplateId)
  self.combine.ItemCombineSrc:SetItemByTemplate(nStoneTemplateId, nHasCount)
  self.combine.ItemCombineSrc.fnClick = self.combine.ItemCombineSrc.DefaultClick
  self.nCombineHasCount = nHasCount
  local nDefaultCombineCount = StoneMgr:GetCombineDefaulCount(nStoneTemplateId)
  local szColor = nHasCount >= nDefaultCombineCount and "White" or "Red"
  self.combine.pPanel:Label_SetColorByName("TxtCombineCount", szColor)
  self.combine.pPanel:Label_SetText("TxtCombineCount", nHasCount .. " / " .. nDefaultCombineCount)
  self.combine.pPanel:Label_SetText("TxtCombineCost", StoneMgr:GetCombineCost(nStoneTemplateId))
end
