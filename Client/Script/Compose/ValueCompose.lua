local ValueComposeClient = Compose.ValueCompose
ValueComposeClient.tbShowData = {}
function ValueComposeClient:UpdateShowData()
  self.tbShowData = {}
  for nSeqId, _ in ipairs(self.tbAllInfo) do
    local tbSeqInfo = self:GetNeedCollectValue(nSeqId)
    if tbSeqInfo then
      for _, tbTemp in ipairs(tbSeqInfo) do
        local nPos = tbTemp.nPos
        if ValueItem.ValueCompose:GetValue(me, nSeqId, nPos) > 0 then
          table.insert(self.tbShowData, nSeqId)
          break
        end
      end
    end
  end
end
function ValueComposeClient:TryComposeValue(nSeqId)
  local bRet, szMsg = self:CheckValueCompose(me, nSeqId)
  if not bRet then
    me.CenterMsg(szMsg)
    return
  end
  RemoteServer.ComposeValueItem(nSeqId)
end
function ValueComposeClient:OnValueComposeFinish(nSeqId)
  self:CheckShowRedPoint()
  local nShowSeqId = 0
  self:UpdateShowData()
  if 0 < #self.tbShowData then
    nShowSeqId = self.tbShowData[1]
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_VALUE_COMPOSE_FINISH, nShowSeqId, nSeqId)
end
function ValueComposeClient:CheckShowRedPoint()
  local bResult = false
  Ui:ClearRedPointNotify("ValueCompose")
  self:UpdateShowData()
  for _, nSeqId in pairs(self.tbShowData) do
    local bIsCanCompose = self:CheckIsFinish(me, nSeqId, true)
    if bIsCanCompose then
      bResult = true
      Ui:SetRedPointNotify("ValueCompose")
      break
    end
  end
  return bResult
end
function ValueComposeClient:OnValueChange(nSeqId, nPos, nOldValue, nNewValue)
  self:CheckShowRedPoint()
  if nPos > 0 and nOldValue == 0 and nOldValue < nNewValue then
    Ui:OpenWindow("Task", Task.TASK_TYPE_VALUE_COMPOSE, nSeqId, nPos, nNewValue - nOldValue)
  end
end
