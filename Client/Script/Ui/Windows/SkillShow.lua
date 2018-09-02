local tbUi = Ui:CreateClass("SkillShow")
tbUi.BG_ITEM_MINI_HEIGHT = 100
tbUi.BG_ITEM_WEIDHT = 500
tbUi.LA_ITEM_MINI_HEIGHT = 40
tbUi.LA_ITEM_WEIDHT = 496
tbUi.tbPanelPos = {155.3, 140}
tbUi.tbOnClick = {
  BtnLevelUp = function(self)
    local nSkillId = self.tbSkillInfo.nId
    local bRet, szMsg = FightSkill:CheckSkillLeveUp(me, nSkillId)
    if not bRet then
      me.CenterMsg(szMsg)
      return
    end
    RemoteServer.OnSkillLevelUp(nSkillId)
  end
}
function tbUi:OnOpen(tbSkillInfo, tbWorldPos)
  if not tbSkillInfo then
    Ui:CloseWindow("SkillShow")
    return
  end
  self:UpdateInfo(tbSkillInfo, tbWorldPos)
end
function tbUi:UpdateInfo(tbSkillInfo, tbWorldPos)
  self.tbSkillInfo = tbSkillInfo
  self:Update(tbWorldPos)
end
function tbUi:Update(tbWorldPos, bNotShowSkillDesc)
  local nExtLevel = self.tbSkillInfo.nExtLevel or 0
  local nSkillLevel = self.tbSkillInfo.nLevel + nExtLevel
  if nSkillLevel < 0 then
    nSkillLevel = 0
  end
  if not self.tbSkillInfo.bHasNoBtnLevelUp then
    if self.tbSkillInfo.bCanLevelUp then
      self.pPanel:SetActive("BtnLevelUp", true)
    else
      self.pPanel:SetActive("BtnLevelUp", false)
    end
  end
  local szLevelText = nSkillLevel .. "/" .. (self.tbSkillInfo.nMaxLevel or FightSkill:GetSkillMaxLevel(self.tbSkillInfo.nId) + FightSkill:GetSkillLimitAddLevel(me, self.tbSkillInfo.nId))
  self.pPanel:Label_SetText("TxtLevel", szLevelText)
  self.pPanel:Label_SetText("SkillName", self.tbSkillInfo.szName)
  local szShowInfo = bNotShowSkillDesc and "" or Lib:Str2LunStr(self.tbSkillInfo.szDesc) .. [[


]]
  szShowInfo = szShowInfo .. "[73cbd5]<当前等级>[-]"
  if self.tbSkillInfo.nRadius ~= 0 and 0 < self.tbSkillInfo.nLevel then
    szShowInfo = szShowInfo .. string.format("\n施展距离：%.1f米", self.tbSkillInfo.nRadius / 100)
  end
  local szCDMsg
  if self.tbSkillInfo.nCD ~= 0 and 0 < self.tbSkillInfo.nLevel then
    szShowInfo = szShowInfo .. string.format("\n施展间隔：%s秒", math.ceil(self.tbSkillInfo.nCD / Env.GAME_FPS))
  end
  local szCurMagicDesc = self.tbSkillInfo.szCurMagicDesc
  if nSkillLevel <= 0 then
    szCurMagicDesc = "?????"
  end
  if not Lib:IsEmptyStr(szCurMagicDesc) then
    szShowInfo = szShowInfo .. "\n技能效果：" .. szCurMagicDesc
  end
  local szMaxMsg
  if self.tbSkillInfo.bMax then
    szShowInfo = szShowInfo .. "\n\n\n[64fa50]<已满级>[-]"
  end
  if not self.tbSkillInfo.bMax and 0 < self.tbSkillInfo.nLevel and not self.tbSkillInfo.bNotNextInfo then
    szShowInfo = szShowInfo .. "\n\n[73cbd5]<下一级>[-]"
    local tbNextSkillInfo = KFightSkill.GetSkillInfo(self.tbSkillInfo.nId, nSkillLevel + 1)
    if self.tbSkillInfo.nRadius ~= 0 then
      if tbNextSkillInfo and tbNextSkillInfo.AttackRadius and 0 < tbNextSkillInfo.AttackRadius then
        szShowInfo = szShowInfo .. string.format("\n施展距离：%.1f米", tbNextSkillInfo.AttackRadius / 100)
      else
        szShowInfo = szShowInfo .. string.format("\n施展距离：%.1f米", self.tbSkillInfo.nRadius / 100)
      end
    end
    if self.tbSkillInfo.nCD ~= 0 then
      if tbNextSkillInfo and tbNextSkillInfo.TimePerCast and 0 < tbNextSkillInfo.TimePerCast then
        szShowInfo = szShowInfo .. string.format("\n施展间隔：%s秒", math.ceil(tbNextSkillInfo.TimePerCast / Env.GAME_FPS))
      else
        szShowInfo = szShowInfo .. string.format("\n施展间隔：%s秒", math.ceil(self.tbSkillInfo.nCD / Env.GAME_FPS))
      end
    end
    if not Lib:IsEmptyStr(self.tbSkillInfo.szNextMagicDesc) then
      szShowInfo = szShowInfo .. "\n技能效果：" .. self.tbSkillInfo.szNextMagicDesc
    end
  end
  self.pPanel:Label_SetText("AttackDamage1", szShowInfo)
  local fSizeY = 0
  local LabelSize = self.pPanel:Label_GetSize("AttackDamage1")
  fSizeY = fSizeY + LabelSize.y
  self.pPanel:ChangePosition("PanelPos", self.tbPanelPos[1], self.tbPanelPos[2])
  self.pPanel:Widget_SetSize("Bg", self.BG_ITEM_WEIDHT, self.BG_ITEM_MINI_HEIGHT + fSizeY)
  self.pPanel:Widget_SetSize("LabelBg", self.LA_ITEM_WEIDHT, self.LA_ITEM_MINI_HEIGHT + fSizeY)
  if tbWorldPos then
    local tbTranPos = self.pPanel:GetRelativePosition("PanelPos", tbWorldPos[1], tbWorldPos[2])
    self.pPanel:ChangePosition("PanelPos", tbTranPos.x + (tbWorldPos[3] or 0), tbTranPos.y + (tbWorldPos[4] or 0) + fSizeY - 50)
  end
end
function tbUi:OnScreenClick()
  Ui:CloseWindow("SkillShow")
end
function tbUi:OnAddSkill(nSkillID, nLevel)
  if not self.tbSkillInfo or self.tbSkillInfo.nId ~= nSkillID then
    return
  end
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_ADD_SKILL,
      self.OnAddSkill
    }
  }
  return tbRegEvent
end
