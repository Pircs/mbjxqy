local tbUi = Ui:CreateClass("FlowerBoxPlay")
tbUi.nSpeed = 100
tbUi.nSpace = 0.6
tbUi.fFlowerBoxCheck = 1
tbUi.fPlayTime = 6
function tbUi:OnOpen(nItemId, szTips, nCount, bShowEffect)
  self:HideAllPlay()
  self:CloseAllTimer()
  if nCount and nCount > 0 then
    for i = 1, nCount do
      table.insert(Gift.tbFlowerBoxPlay, {
        [1] = nItemId,
        [2] = szTips,
        [3] = bShowEffect
      })
    end
  end
  self:TryPlayFlowerBox()
end
function tbUi:HideAllPlay()
  self.pPanel:SetActive("99meigui", false)
  self.pPanel:SetActive("99xingyuncao", false)
end
function tbUi:Play(nItemId)
  if nItemId == Gift.nRoseBoxId then
    self.pPanel:SetActive("99meigui", true)
  elseif nItemId == Gift.nGrassBoxId then
    self.pPanel:SetActive("99xingyuncao", true)
  end
end
function tbUi:PlayFlowerBox()
  local nItemId = Gift.tbFlowerBoxPlay[1][1]
  local szTips = Gift.tbFlowerBoxPlay[1][2]
  local bShowEffect = Gift.tbFlowerBoxPlay[1][3]
  if bShowEffect then
    self:Play(nItemId)
    Timer:Register(self.fPlayTime * Env.GAME_FPS, self.HideAllPlay, self)
  end
  Ui:OnWorldNotify(szTips or "", 0, 1)
end
function tbUi:OnNoticeFinish()
  if next(Gift.tbFlowerBoxPlay) then
    table.remove(Gift.tbFlowerBoxPlay, 1)
  end
end
function tbUi:TryPlayFlowerBox()
  local bIsFinish = self:CheckSystemNoticeIsFinish()
  if bIsFinish then
    self:PlayFlowerBox()
    local nItemId = Gift.tbFlowerBoxPlay[1][1]
    local szTips = Gift.tbFlowerBoxPlay[1][2]
    self.pPanel:Label_SetText("Msg", szTips)
    me.Msg(szTips, ChatMgr.SystemMsgType.System)
    local tbSize = self.pPanel:Label_GetSize("Msg")
    local nLength = tbSize.x + 500
    local nTime = nLength / self.nSpeed
    local nWaitTime = (nTime + self.nSpace) * Env.GAME_FPS
    self:CloseAllTimer()
    Timer:Register(nWaitTime, self.FlowerBoxCacheCheck, self, true)
    Timer:Register(nWaitTime - 1, self.OnNoticeFinish, self)
  elseif not self.nFlowerBoxTimerId then
    self.nFlowerBoxTimerId = Timer:Register(self.fFlowerBoxCheck * Env.GAME_FPS, self.FlowerBoxCacheCheck, self)
  end
end
function tbUi:FlowerBoxCacheCheck(bJustOneCheck)
  if #Gift.tbFlowerBoxPlay == 0 then
    self:CloseAnim()
    return false
  end
  if bJustOneCheck or self:CheckSystemNoticeIsFinish() then
    self:TryPlayFlowerBox()
    return false
  end
  return true
end
function tbUi:CloseAnim()
  self.nFlowerBoxTimerId = nil
  Ui:CloseWindow("GiftPlay")
end
function tbUi:CheckSystemNoticeIsFinish()
  if not Ui:WindowVisible("SystemNotice") then
    return true
  end
  return Ui("SystemNotice"):CheckFinish()
end
function tbUi:OnClose()
  self:CloseAllTimer()
end
function tbUi:CloseAllTimer()
  if self.nFlowerBoxTimerId then
    Timer:Close(self.nFlowerBoxTimerId)
    self.nFlowerBoxTimerId = nil
  end
end
