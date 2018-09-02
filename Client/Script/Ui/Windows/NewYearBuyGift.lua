local tbUi = Ui:CreateClass("NewYearBuyGift")
function tbUi:GetItemIdFromAward(tbAward)
  for _, v2 in ipairs(tbAward) do
    if Player.AwardType[v2[1]] == Player.award_type_item then
      return v2[2]
    end
  end
end
function tbUi:OnOpen()
  Client:SetFlag("SeeRedNewYearBuyGift", Lib:GetLocalDay(GetTime() - 14400))
  Recharge:CheckRedPoint()
  self.pPanel:Label_SetText("Txt1", Recharge.tbNewYearBuyGiftActSetting.szPanelLine1)
  self.pPanel:Label_SetText("Txt2", Recharge.tbNewYearBuyGiftActSetting.szPanelLine2)
  self.pPanel:Texture_SetTexture("Container", Recharge.tbNewYearBuyGiftActSetting.szTextureInPanel)
  local tbUiData, tbActData = Activity:GetActUiSetting("RechargeNewYearBuyGift")
  local szAwardKey = tbUiData.szAwardKey
  local tbStartTime = os.date("*t", tbActData.nStartTime)
  local tbEndTime = os.date("*t", tbActData.nEndTime)
  self.pPanel:Label_SetText("Tip", string.format("购买期限：%s年%s月%s日-%s月%s日", tbStartTime.year, tbStartTime.month, tbStartTime.day, tbEndTime.month, tbEndTime.day))
  local nToday = Lib:GetLocalDay()
  local nEndActDay = Lib:GetLocalDay(tbActData.nEndTime)
  local tbNewYearBuyProds = Recharge.tbSettingGroup.YearGift
  local tbShowPrds = {}
  for i, v in ipairs(tbNewYearBuyProds) do
    if v[szAwardKey] then
      table.insert(tbShowPrds, v)
    end
  end
  local function fnSetItem(tbItemObj, index)
    local tbProductInfo = tbShowPrds[index]
    local tbBuyData = Recharge.tbNewYearBuySetting[tbProductInfo.nGroupIndex]
    local nItemId = self:GetItemIdFromAward(tbProductInfo[szAwardKey])
    local tbItembase = KItem.GetItemBaseProp(nItemId)
    tbItemObj.pPanel:Label_SetText("ShowPrice", tbProductInfo.szNoromalDesc)
    local szShowBuyPrice = Recharge:GetShowBuyPriceDesc(tbProductInfo.nMoney, tbProductInfo.szMoneyType)
    tbItemObj.pPanel:Label_SetText("GoldTxt", szShowBuyPrice)
    local nParamId = KItem.GetItemExtParam(nItemId, 1)
    local _, _, tbItems = Item:GetClass("RandomItem"):RandomItemAward(me, nParamId, "NewYearBuyGift")
    for i = 1, 6 do
      local tbItem = tbItems[i]
      local tbGrid = tbItemObj["itemframe" .. i]
      if tbItem then
        tbGrid.pPanel:SetActive("Main", true)
        tbGrid:SetGenericItem(tbItem)
        tbGrid.fnClick = tbGrid.DefaultClick
      else
        tbGrid.pPanel:SetActive("Main", false)
      end
    end
    local bBuyed = false
    local nHasBuyCount = 0
    if tbBuyData.nSaveCountKey and 1 < tbBuyData.nBuyCount then
      nHasBuyCount = me.GetUserValue(Recharge.SAVE_GROUP, tbBuyData.nSaveCountKey)
      if nHasBuyCount >= tbBuyData.nBuyCount then
        bBuyed = true
      elseif me.GetUserValue(Recharge.SAVE_GROUP, tbProductInfo.nBuyDayKey) == Recharge:GetRefreshDay() then
        bBuyed = true
      end
    elseif 0 < me.GetUserValue(Recharge.SAVE_GROUP, tbProductInfo.nBuyDayKey) then
      bBuyed = true
      nHasBuyCount = 1
    end
    local szCanbuyDay
    if tbBuyData.nCanBuyDay and tbBuyData.nCanBuyDay ~= 0 then
      local nCanbuyTime = tbActData.nStartTime + 86400 * tbBuyData.nCanBuyDay
      if nCanbuyTime > tbActData.nEndTime then
        nCanbuyTime = tbActData.nEndTime
      end
      local nDay = Lib:GetLocalDay(nCanbuyTime)
      if nDay > nToday then
        local tbDate = os.date("*t", nCanbuyTime)
        szCanbuyDay = string.format("%s月%s日\n开放购买", tbDate.month, tbDate.day)
      end
    end
    if szCanbuyDay then
      tbItemObj.pPanel:SetActive("Unopen", true)
      tbItemObj.pPanel:SetActive("GetTran", false)
      tbItemObj.pPanel:Label_SetText("Unopen", szCanbuyDay)
    else
      tbItemObj.pPanel:SetActive("Unopen", false)
      tbItemObj.pPanel:SetActive("GetTran", true)
    end
    local nLeftBuyCount = tbBuyData.nBuyCount - nHasBuyCount
    if nLeftBuyCount > 0 then
      local szSuffix = bBuyed and "，[FFFE0D]每日4点刷新购买[-]" or ""
      tbItemObj.pPanel:Label_SetText("Title", string.format("%s（可购[FFFE0D]%d[-]个%s）", tbItembase.szName, nLeftBuyCount, szSuffix))
    else
      tbItemObj.pPanel:Label_SetText("Title", string.format("%s", tbItembase.szName))
    end
    if bBuyed then
      tbItemObj.pPanel:SetActive("HaveBuy", true)
      if nLeftBuyCount > 0 then
        tbItemObj.pPanel:Label_SetText("HaveBuy", "今日已购")
      else
        tbItemObj.pPanel:Label_SetText("HaveBuy", "已购买")
      end
      tbItemObj.pPanel:SetActive("BtnGet", false)
    else
      tbItemObj.pPanel:SetActive("HaveBuy", false)
      tbItemObj.pPanel:SetActive("BtnGet", true)
      function tbItemObj.BtnGet.pPanel.OnTouchEvent(tbButton)
        Recharge:RequestBuyYearGift(tbProductInfo.ProductId)
      end
    end
  end
  self.ScrollView:Update(tbShowPrds, fnSetItem)
end
