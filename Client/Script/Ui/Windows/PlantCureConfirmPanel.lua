local tbUi = Ui:CreateClass("PlantCureConfirmPanel")
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnSure()
  RemoteServer.CurePlant(House.dwOwnerId, self.nState, self.bCost)
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:CheckTips()
  self.bCost = not self.bCost
  Client:SetFlag("PlantCureConfirm_Cost", self.bCost)
  self:Refresh()
end
function tbUi:OnOpen(nState)
  self.bCost = Client:GetFlag("PlantCureConfirm_Cost") or false
  self.nState = nState
  self.pPanel:Toggle_SetChecked("CheckTips", self.bCost)
  self:Refresh()
end
function tbUi:Refresh()
  local tbSetting = HousePlant.tbSickStateSetting[self.nState]
  local szNotify = tbSetting.szCureNotify
  if self.bCost then
    szNotify = string.format(szNotify, Lib:TimeFullDesc(HousePlant.CURE_TIME_COST))
  else
    szNotify = string.format(szNotify, Lib:TimeFullDesc(HousePlant.CURE_TIME_NORMAL))
  end
  self.pPanel:Label_SetText("Label", szNotify)
  local szCost = string.format("[92D2FF][FFFE0D]%d元宝[-]使用高级%s，可得[FFFE0D]%d贡献[-][-]", HousePlant.CURE_COST, tbSetting.szCureTool, HousePlant.CURE_COST_AWARD)
  self.pPanel:Label_SetText("RepeatTips", szCost)
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
