local tbTitle = Ui:CreateClass("TitleChangePanel")
local RepresentSetting = luanet.import_type("RepresentSetting")
tbTitle.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnChange = function(self)
    if not self.tbSelectInfo then
      me.CenterMsg("暂未获得称号")
      return
    end
    RemoteServer.ActiveTitle(self.tbSelectInfo.nTitleID)
  end,
  BtnHide = function(self)
    RemoteServer.ActiveTitle(0)
  end
}
function tbTitle:OnOpen()
  self.tbSortTitle = {}
  self.tbSelectInfo = nil
  self:UpdateScrollView()
  if #self.tbSortTitle > 0 then
    self.pPanel:Label_SetText("TxtInfo", self.tbSortTitle[1].tbTitleTemp.Desc)
  else
    self.pPanel:Label_SetText("TxtInfo", "")
  end
end
function tbTitle:UpdateScrollView()
  local tbTitleData = PlayerTitle:GetPlayerTitleData()
  local tbAllTitle = {}
  for _, tbTitle in pairs(tbTitleData.tbAllTitle) do
    local tbTitleInfo = {}
    tbTitleInfo.nTitleID = tbTitle.nTitleID
    tbTitleInfo.nEndTime = tbTitle.nEndTime
    tbTitleInfo.szText = tbTitle.szText
    local tbTitleTemp = PlayerTitle:GetTitleTemplate(tbTitleInfo.nTitleID)
    tbTitleInfo.tbTitleTemp = tbTitleTemp
    table.insert(tbAllTitle, tbTitleInfo)
  end
  table.sort(tbAllTitle, function(a, b)
    return a.tbTitleTemp.Rank > b.tbTitleTemp.Rank
  end)
  local function fnOnTouchEvent(tbItemObj)
    self.tbSelectInfo = tbItemObj.tbTitleInfo
    self.pPanel:Label_SetText("TxtInfo", self.tbSelectInfo.tbTitleTemp.Desc)
  end
  local function fnUpdateTitle(tbItemObj, nIndex)
    local tbInfo = tbAllTitle[nIndex]
    local tbCurTemp = tbInfo.tbTitleTemp
    local szName = tbInfo.szText
    if Lib:IsEmptyStr(szName) then
      szName = tbCurTemp.Name
    end
    tbItemObj.pPanel:Label_SetText("Title", szName)
    local MainColor = RepresentSetting.GetColorSet(tbCurTemp.ColorID)
    tbItemObj.pPanel:Label_SetColor("Title", MainColor.r * 255, MainColor.g * 255, MainColor.b * 255)
    if tbCurTemp.GTopColorID > 0 and 0 < tbCurTemp.GBottomColorID then
      local GTopColor = RepresentSetting.GetColorSet(tbCurTemp.GTopColorID)
      local GTBottomColor = RepresentSetting.GetColorSet(tbCurTemp.GBottomColorID)
      tbItemObj.pPanel:Label_SetGradientByColor("Title", GTopColor, GTBottomColor)
    else
      tbItemObj.pPanel:Label_SetGradientActive("Title", false)
    end
    local ColorOuline = RepresentSetting.CreateColor(0, 0, 0, 1)
    if 0 < tbCurTemp.OutlineColorID then
      ColorOuline = RepresentSetting.GetColorSet(tbCurTemp.OutlineColorID)
    end
    tbItemObj.pPanel:Label_SetOutlineColor("Title", ColorOuline)
    if 0 < tbInfo.nEndTime then
      tbItemObj.pPanel:Label_SetText("Time", os.date("%Y-%m-%d %H:%M:%S", tbInfo.nEndTime))
    else
      tbItemObj.pPanel:Label_SetText("Time", "")
    end
    tbItemObj.tbTitleInfo = tbInfo
    tbItemObj.pPanel.OnTouchEvent = fnOnTouchEvent
    tbItemObj.pPanel:Toggle_SetChecked("Main", false)
    if nIndex == 1 then
      fnOnTouchEvent(tbItemObj)
    end
  end
  self.tbSortTitle = tbAllTitle
  self.ScrollView:Update(#tbAllTitle, fnUpdateTitle)
end
function tbTitle:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_UPDATE_TITLE,
      self.UpdateScrollView
    }
  }
  return tbRegEvent
end
