local tbUi = Ui:CreateClass("SwornFriendsTitlePanel")
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnCancel = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnSure = function(self)
    self:Confirm()
  end
}
function tbUi:OnOpen()
  if not TeamMgr:IsCaptain() then
    Log("SwornFriendsTitlePanel, not captain")
    return false
  end
  local tbMembers = TeamMgr:GetTeamMember()
  local szCount = SwornFriends:GetMemberCountDesc(#tbMembers + 1)
  self.szCount = szCount
  self.pPanel:Label_SetText("Txt", szCount)
end
function tbUi:Confirm()
  local szHead = self.pPanel:Input_GetText("TxtTitle1")
  local szTail = self.pPanel:Input_GetText("TxtTitle2")
  local bOk
  bOk, szHead, szTail = SwornFriends:CheckMainTitle(szHead, szTail)
  if not bOk then
    me.CenterMsg(szHead)
    return
  end
  local function fnConfirm()
    SwornFriends:ConnectReq(szHead, szTail)
  end
  me.MsgBox(string.format("你们确定以[FFFE0D]%s%s%s[-]之名进行结拜吗？", szHead, self.szCount, szTail), {
    {"确定", fnConfirm},
    {"取消"}
  })
  Ui:CloseWindow(self.UI_NAME)
end
