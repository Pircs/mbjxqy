local tbUi = Ui:CreateClass("BattleEntrance")
local szOpenTimeDesz = [[
16:30~17:00,
20:30~21:00,
22:30~23:00]]
function tbUi:OnOpen()
  self.pPanel:Label_SetText("TxtTime", szOpenTimeDesz)
  local nLeftTimes = DegreeCtrl:GetDegree(me, "Battle")
  self:RefreshName()
  self.pPanel:Label_SetText("TxtTimes", string.format("%d/%d", nLeftTimes, DegreeCtrl:GetMaxDegree("Battle", me)))
  self.pPanel:SetActive("BtnPlus", nLeftTimes <= 0)
  self.pPanel:SetActive("Tips2", false)
end
function tbUi:RefreshName()
  local tbBattleSetting = Battle:GetCanSignBattleSetting(me)
  self.pPanel:Label_SetText("TxtTips", tbBattleSetting and "战场报名中" or "战场暂未开放")
  local szName = tbBattleSetting and tbBattleSetting.szName or ""
  self.pPanel:Label_SetText("TxtType", szName)
end
function tbUi:OnClose()
  if self.nTimer then
    Timer:Close(self.nTimer)
  end
end
function tbUi:CheckAddTimes()
  if DegreeCtrl:GetDegree(me, "BattleAdd") > 0 then
    local nTemplateId = Item:GetClass("CountAddProp"):GetAddDegreeItemId("Battle")
    if nTemplateId then
      do
        local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)
        local nCount, tbItem = me.GetItemCountInAllPos(nTemplateId)
        if nCount > 0 then
          local function fnAgree()
            local _, pItem = next(tbItem)
            if pItem then
              RemoteServer.UseItem(pItem.dwId)
            end
          end
          Ui:OpenWindow("MessageBox", string.format("您的战场次数不足，需要消耗[FFFE0D]%s[-]增加次数吗", tbBaseInfo.szName), {
            {fnAgree},
            {}
          }, {"同意", "取消"})
          return
        end
        Ui:OpenWindow("ItemTips", "Item", nil, nTemplateId)
        me.CenterMsg("您缺少" .. tbBaseInfo.szName)
      end
    end
  else
    me.CenterMsg("今日参加战场的次数已经全部用完，请大侠明日再来")
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnBack()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnPlus()
  self:CheckAddTimes()
end
function tbUi.tbOnClick:BtnJoin()
  local tbBattleSetting = Battle:GetCanSignBattleSetting(me)
  if not tbBattleSetting then
    me.CenterMsg("战场暂未开放")
    return
  end
  if not tbBattleSetting.nQualifyTitleId then
    local nDegree = DegreeCtrl:GetDegree(me, "Battle")
    if nDegree <= 0 then
      self:CheckAddTimes()
      return
    end
  end
  RemoteServer.BattleSignUp()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:RegisterEvent()
  return {
    {
      UiNotify.emNOTIFY_BUY_DEGREE_SUCCESS,
      self.OnOpen
    }
  }
end
