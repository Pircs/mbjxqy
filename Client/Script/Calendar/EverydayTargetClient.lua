EverydayTarget.tbShowAward = {
  [1] = {
    {"BasicExp", 30},
    {"Gold", 50}
  },
  [2] = {
    {"BasicExp", 30},
    {"Gold", 100}
  },
  [3] = {
    {"BasicExp", 30},
    {"Gold", 200}
  },
  [4] = {
    {"BasicExp", 30},
    {"Gold", 300}
  },
  [5] = {
    {"BasicExp", 30},
    {"Gold", 500}
  }
}
function EverydayTarget:OnLogin()
  self:CheckRedpoint()
end
function EverydayTarget:GetTargetList()
  local tbList = {}
  local szCompleteColor = "[47f005]"
  local szNotComColor = "[-]"
  local nTodayLevel = self:GetTodayLevel(me)
  for szKey, tbInfo in pairs(self.tbEverydaySetting) do
    local _, nValue = self:GetCountAndValue(nTodayLevel, szKey)
    local nCurCount, nAllCount, nActiveValue = self:GetTargetCurActive(me, szKey)
    local nMinLevel = self:GetMinLevel(szKey)
    local bOpenToday = self:IsOpenToday(szKey)
    if bOpenToday and nAllCount > 0 and nMinLevel <= me.nLevel then
      local tbTarget = {}
      local szColor = nActiveValue > 0 and szCompleteColor or szNotComColor
      tbTarget.bComplete = nActiveValue > 0
      tbTarget.szKey = szKey
      tbTarget.szName = string.format("%s%s", szColor, tbInfo.szName)
      tbTarget.szTimes = string.format("%s%d/%d", szColor, nCurCount, nAllCount)
      tbTarget.szValue = string.format("%s+%d", szColor, nValue)
      table.insert(tbList, tbTarget)
    end
  end
  return tbList
end
function EverydayTarget:GetMinLevel(szKey)
  local nCalendarId = Calendar:GetActivityId(szKey)
  if nCalendarId then
    local nMinLevel = Calendar:GetActivityLevelMin(nCalendarId)
    return nMinLevel
  else
    return 20
  end
end
function EverydayTarget:OnValueChanged(szMsg)
  if szMsg then
    me.CenterMsg(szMsg)
  end
  self:CheckRedpoint()
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_EVERYDAY_TARGET)
end
function EverydayTarget:CheckRedpoint()
  local bHasAward = self:IsHadAward(me)
  if bHasAward and me.nLevel >= self.Def.OPEN_LEVEL then
    Ui:SetRedPointNotify("Calendar_EverydayTarget")
    local nRet = Guide.tbNotifyGuide:IsFinishGuide("EverydayTarget_First")
    if nRet and nRet == 0 then
      Ui:SetRedPointNotify("NG_EverydayTarget_First")
    else
      Ui:ClearRedPointNotify("NG_EverydayTarget_First")
    end
  else
    Ui:ClearRedPointNotify("NG_EverydayTarget_First")
    Ui:ClearRedPointNotify("Calendar_EverydayTarget")
  end
end
function EverydayTarget:CheckDataVersion()
  self:CheckRedpoint()
  if self:CheckNewDay(me) then
    RemoteServer.TryUpdateDailyTargetData()
  end
end
function EverydayTarget:GetTrack(szKey)
  local tbSetting = self.tbEverydaySetting[szKey]
  if not tbSetting or Lib:IsEmptyStr(tbSetting.szTrack) then
    return
  end
  return tbSetting.szTrack, tbSetting.tbParam
end
EverydayTarget.tbLinkCalendarKey = {Battle = "BattleMoba"}
function EverydayTarget:IsOpenToday(szKey)
  local nCalendarId = Calendar:GetActivityId(szKey)
  if not nCalendarId then
    return true
  end
  if not Calendar:IsAdditionalShowActivity(szKey) then
    return false
  end
  if not Calendar:IsTimeLimit(nCalendarId) then
    return true
  end
  local tbOpenTime = Calendar:GetTodayOpenTime(nCalendarId, 14400)
  if #tbOpenTime == 0 then
    local szLinkKey = self.tbLinkCalendarKey[szKey]
    if szLinkKey and not self.tbLinkCalendarKey[szLinkKey] then
      return self:IsOpenToday(szLinkKey)
    end
  end
  return #tbOpenTime > 0
end
