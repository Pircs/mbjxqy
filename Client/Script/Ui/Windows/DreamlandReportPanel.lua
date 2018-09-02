local tbUi = Ui:CreateClass("DreamlandReportPanel")
tbUi.tbStateName = {
  [2] = "第一阶段",
  [4] = "第二阶段",
  [6] = "第三阶段",
  [8] = "第四阶段"
}
function tbUi:OnOpen()
  local nTimeNow = GetTime()
  if not self.nLastRequetTime or nTimeNow > self.nLastRequetTime + 3 then
    RemoteServer.InDifferBattleRequestInst("RequestTeamScore")
  end
  self:Update()
end
function tbUi:Update()
  if InDifferBattle.dwWinnerTeam == TeamMgr:GetTeamId() then
    self.pPanel:SetActive("Failure", false)
    self.pPanel:SetActive("Victory", true)
    self.pPanel:SetActive("Battlefield", false)
  else
    self.pPanel:SetActive("Victory", false)
    self.pPanel:SetActive("Failure", false)
    self.pPanel:SetActive("Battlefield", true)
  end
  local tbMembers = InDifferBattle.tbTeamMemberInfos or TeamMgr:GetTeamMember()
  local tbTeamReportInfo = InDifferBattle.tbTeamReportInfo
  local nTotalKill = 0
  local nTotalScore = 0
  for ith = 1, 3 do
    local tbMemberData = tbMembers[ith - 1]
    if ith == 1 then
      tbMemberData = TeamMgr:GetMyTeamMemberData()
    end
    local tbNode = self["Teammate" .. ith]
    if tbMemberData then
      tbNode.pPanel:SetActive("Main", true)
      local tbSocreInfo = tbTeamReportInfo[tbMemberData.nPlayerID] or {}
      local szFactionIcon = Faction:GetIcon(tbMemberData.nFaction)
      tbNode.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon)
      local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbMemberData.nPortrait)
      tbNode.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas)
      tbNode.pPanel:Label_SetText("lbLevel", tbMemberData.nLevel)
      local nHonorLevel = tbSocreInfo.nHonorLevel or tbMemberData.nHonorLevel
      local tbHonorInfo = Player.tbHonorLevelSetting[nHonorLevel]
      if tbHonorInfo then
        tbNode.pPanel:Sprite_Animation("PlayerTitle", tbHonorInfo.ImgPrefix)
      end
      tbNode.pPanel:Label_SetText("RoleName", tbMemberData.szName)
      if tbSocreInfo.nDeathState and self.tbStateName[tbSocreInfo.nDeathState] then
        tbNode.pPanel:SetActive("ConditionDeath", true)
        tbNode.pPanel:SetActive("ConditionSurvival", false)
        tbNode.pPanel:Label_SetText("ConditionDeath", string.format("%s阵亡", self.tbStateName[tbSocreInfo.nDeathState]))
      else
        tbNode.pPanel:SetActive("ConditionDeath", false)
        tbNode.pPanel:SetActive("ConditionSurvival", true)
      end
      tbNode.pPanel:Label_SetText("KillNumber", tbSocreInfo.nKillCount or 0)
      nTotalKill = nTotalKill + (tbSocreInfo.nKillCount or 0)
      local nScore = tbSocreInfo.nScore or 0
      local nGrade, tbGrade = InDifferBattle:GetEvaluationFromScore(nScore)
      tbNode.pPanel:Label_SetText("Integral", string.format("%d[%s]（%s）[-]", nScore, tbGrade.szColor, tbGrade.szName))
      nTotalScore = nTotalScore + nScore
    else
      tbNode.pPanel:SetActive("Main", false)
    end
  end
  self.pPanel:Label_SetText("KillTotal", string.format("[73cad4]击杀总数：[-]%d", nTotalKill))
  self.pPanel:Label_SetText("IntegralTotal", string.format("[73cad4]总积分：[-]%d", nTotalScore))
end
function tbUi:OnSyncUiData(szType)
  if szType ~= "BattleScore" then
    return
  end
  self:Update()
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_INDIFFER_BATTLE_UI,
      self.OnSyncUiData
    }
  }
  return tbRegEvent
end
