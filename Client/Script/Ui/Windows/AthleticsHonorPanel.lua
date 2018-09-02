local tbUi = Ui:CreateClass("AthleticsHonor")
tbUi.tbDivisionBg = {
  "Rank1",
  "Rank2",
  "Rank3",
  "Rank4",
  "Rank5"
}
tbUi.tbAthleticsAct = {
  Battle = {
    szName = "宋金战场",
    tbDivisionIcon = {
      "Honor_sjzc",
      "Honor_sjzc",
      "Honor_sjzc",
      "Honor_sjzc",
      "Honor_sjzc"
    },
    szYear = "年度战场将于[FFFE0D]%s 20:30-21:00[-]开启\n\n[C8FF00]资格获得方式[-]：\n开赛前取得[FFFE0D]季度战场前20[-]",
    szQuarter = "季度战场将于[FFFE0D]%s 20:30-21:00[-]开启\n\n[C8FF00]资格获得方式[-]：\n开赛前取得[FFFE0D]月度战场前20[-]",
    szMonth = "月度战场将于[FFFE0D]%s 20:30-21:00[-]开启\n\n[C8FF00]开赛前达成以下任意一项获取资格[-]：\n普通战场进入[FFFE0D]前3[-]\n跨服战场进入[FFFE0D]前10[-]\n百人战场进入[FFFE0D]前20[-]"
  },
  TeamBattle = {
    szName = "通天塔",
    tbDivisionIcon = {
      "Honor_ttt",
      "Honor_ttt",
      "Honor_ttt",
      "Honor_ttt",
      "Honor_ttt"
    },
    szQuarter = "季度通天塔将于[FFFE0D]%s [-]开启\n\n[C8FF00]资格获得方式[-]：\n开赛前登上[FFFE0D]月度通天塔赛7层[-]以上",
    szMonth = "月度通天塔将于[FFFE0D]%s [-]开启\n\n[C8FF00]资格获得方式[-]：\n开赛前登上[FFFE0D]通天塔7层[-]以上"
  },
  InDifferBattle = {
    szName = "心魔幻境",
    tbDivisionIcon = {
      "Honor_xmhj",
      "Honor_xmhj",
      "Honor_xmhj",
      "Honor_xmhj",
      "Honor_xmhj"
    },
    szQuarter = "季度心魔幻境将于[FFFE0D]%s [-]开启\n\n[C8FF00]资格获得方式[-]：\n开赛前获得过[FFFE0D]月度心魔幻境良好[-]及以上评价",
    szMonth = "月度心魔幻境将于[FFFE0D]%s [-]开启\n\n[C8FF00]资格获得方式[-]：\n开赛前获得过[FFFE0D]心魔幻境良好[-]及以上评价"
  },
  FactionBattle = {
    szName = "门派竞技",
    tbDivisionIcon = {
      "Honor_mpjj",
      "Honor_mpjj",
      "Honor_mpjj",
      "Honor_mpjj",
      "Honor_mpjj"
    }
  },
  HuaShanLunJian = {
    szName = "华山论剑",
    tbDivisionIcon = {
      "Honor_hslj",
      "Honor_hslj",
      "Honor_hslj",
      "Honor_hslj",
      "Honor_hslj"
    }
  },
  QunYingHui = {
    szName = "群英会",
    tbDivisionIcon = {
      "Honor_qyh",
      "Honor_qyh",
      "Honor_qyh",
      "Honor_qyh",
      "Honor_qyh"
    }
  }
}
tbUi.tbTexiaoName = {
  "",
  "Texaio_qingtong",
  "Texaio_baiyin",
  "Texaio_huangjin",
  "Texaio_baijin"
}
tbUi.tbActList = {
  "Battle",
  "TeamBattle",
  "InDifferBattle",
  "FactionBattle",
  "HuaShanLunJian",
  "QunYingHui"
}
function tbUi:OnOpenEnd()
  local fnOpenTip = function(szKey)
    if Calendar.tbUnopenHonor[szKey] then
      return
    end
    Ui:OpenWindow("AthleticsHonorTip", szKey)
  end
  local tbShowList = self:GetShowList()
  local function fnSetItem(itemObj, nIdx)
    local szKey = tbShowList[nIdx]
    local tbInfo = self.tbAthleticsAct[szKey]
    itemObj.pPanel:Label_SetText("Name", tbInfo.szName)
    local nDivision = Calendar:GetDivision(me, szKey)
    local tbHonorInfo = Calendar.tbHonorInfo[szKey]
    itemObj.NameIcon.pPanel:SetActive("Mask", nDivision == 0)
    local szNextDivision = Calendar.tbDivisionKey[nDivision + 1]
    local bShow = not Calendar.tbUnopenHonor[szKey]
    if bShow and szNextDivision and tbHonorInfo[szNextDivision] and tbHonorInfo[szNextDivision][1] then
      itemObj.pPanel:SetActive("BarBg", true)
      local nRequire = tbHonorInfo[Calendar.tbDivisionKey[nDivision + 1]][1]
      local nCur = me.GetUserValue(Calendar.GROUP, tbHonorInfo.nJoinTimesKey)
      itemObj.pPanel:Sprite_SetFillPercent("Bar", nCur / nRequire)
    else
      itemObj.pPanel:SetActive("BarBg", false)
    end
    for i = 1, #Calendar.tbDivisionKey do
      itemObj.pPanel:SetActive("RankName" .. i, i == nDivision)
    end
    itemObj.pPanel:SetActive("BarTxt", bShow)
    if bShow then
      local szPoint = nDivision > 0 and Calendar.DIVISION_HOUR[nDivision] or 0
      itemObj.pPanel:Label_SetText("BarTxt", string.format("本月荣誉：%d", szPoint))
    end
    local tbTxt = {
      "szMonth",
      "szQuarter",
      "szYear"
    }
    local bShowTick = false
    for i = 1, 3 do
      local bShow = tbInfo[tbTxt[i]] and not Calendar.tbUnopenHonor[szKey]
      local szTF = Calendar:GetTicketOpenTimeFrame(szKey, i)
      bShow = bShow and (Lib:IsEmptyStr(szTF) or GetTimeFrameState(szTF) == 1)
      itemObj.pPanel:SetActive("Ticket" .. i, bShow or false)
      bShowTick = bShowTick or bShow
    end
    itemObj.pPanel:SetActive("Unopen", not bShowTick)
    itemObj.pPanel:SetActive("Unopen1", Calendar.tbUnopenHonor[szKey] or false)
    nDivision = math.max(1, nDivision)
    local szIconName = tbInfo.tbDivisionIcon[nDivision]
    itemObj.NameIcon.pPanel:Sprite_SetSprite("Main", szIconName)
    itemObj.NameIcon.pPanel:Button_SetSprite("Main", szIconName)
    local szRank = string.format("UI/Textures/%s.png", self.tbDivisionBg[nDivision])
    itemObj.NameIcon.pPanel:Texture_SetTexture("Rank", szRank)
    for _, szTexiao in pairs(self.tbTexiaoName) do
      if not Lib:IsEmptyStr(szTexiao) then
        itemObj.NameIcon.pPanel:SetActive(szTexiao, _ == nDivision)
      end
    end
    function itemObj.NameIcon.pPanel.OnTouchEvent()
      fnOpenTip(szKey)
    end
    for i = 1, 3 do
      local bHadTicket = Calendar:CheckPlayerTicket(szKey, i)
      itemObj["Ticket" .. i].pPanel:SetActive("Mask" .. i, not bHadTicket)
      itemObj["Ticket" .. i].pPanel.OnTouchEvent = function()
        local _, szDesc = Calendar:GetNextOpenTime(szKey, i)
        szDesc = string.format(tbInfo[tbTxt[i]], szDesc or "")
        Ui:OpenWindow("TxtTipPanel", szDesc)
      end
    end
  end
  self.ScrollView:Update(#tbShowList, fnSetItem)
end
function tbUi:GetShowList()
  local tbShow = {}
  for _, szAct in ipairs(self.tbActList) do
    local szTF, nLevel = Calendar:GetActOpenInfo(szAct)
    if (Lib:IsEmptyStr(szTF) or GetTimeFrameState(szTF) == 1) and nLevel <= me.nLevel then
      table.insert(tbShow, szAct)
    end
  end
  return tbShow
end
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end
}
local tbTip = Ui:CreateClass("AthleticsHonorTip")
tbTip.tbDesc = {
  Battle = {
    "[C8FF00]本月达成任意一项：[-]\n战场前[FFFE0D] 15 [-]名\n跨服战场前[FFFE0D] 20 [-]名\n百人战场前[FFFE0D] 50 [-]名\n参加[FFFE0D] 任意战场 (%d/4) [-]",
    "[C8FF00]本月达成任意一项：[-]\n战场前[FFFE0D] 8 [-]名\n跨服战场前[FFFE0D] 12 [-]名\n百人战场前[FFFE0D] 30 [-]名\n参加[FFFE0D] 任意战场 (%d/8) [-]",
    "[C8FF00]本月达成任意一项：[-]\n战场前[FFFE0D] 4 [-]名\n跨服战场前[FFFE0D] 6 [-]名\n百人战场前[FFFE0D] 15 [-]名\n参加[FFFE0D] 任意战场 (%d/16)[-]",
    "[C8FF00]本月达成任意一项：[-]\n战场前[FFFE0D] 2 [-]名\n跨服战场前[FFFE0D] 3 [-]名\n百人战场前[FFFE0D] 6 [-]名",
    "[C8FF00]本月达成任意一项：[-]\n跨服战场第[FFFE0D] 1 [-]名\n百人战场前[FFFE0D] 3 [-]名"
  },
  TeamBattle = {
    "[C8FF00]本月达成任意一项：[-]\n登上通天塔[FFFE0D] 4 [-]层\n参加通天塔[FFFE0D] (%d/2) [-]",
    "[C8FF00]本月达成任意一项：[-]\n登上通天塔[FFFE0D] 5 [-]层\n参加通天塔[FFFE0D] (%d/4) [-]",
    "[C8FF00]本月达成任意一项：[-]\n登上通天塔[FFFE0D] 6 [-]层\n参加通天塔[FFFE0D] (%d/8) [-]",
    "[C8FF00]本月达成：[-]\n登上通天塔[FFFE0D] 7 [-]层",
    "[C8FF00]本月达成：[-]\n登上通天塔[FFFE0D] 8 [-]层"
  },
  FactionBattle = {
    "[C8FF00]本月达成任意一项：[-]\n初赛成绩进入前[FFFE0D] 60%% [-]\n参加门派竞技[FFFE0D] (%d/2) [-]",
    "[C8FF00]本月达成任意一项：[-]\n进入[FFFE0D] 十六强 [-]\n参加门派竞技[FFFE0D] (%d/3) [-]",
    "[C8FF00]本月达成任意一项：[-]\n进入[FFFE0D] 八强 [-]\n参加门派竞技[FFFE0D] (%d/4) [-]",
    "[C8FF00]本月达成：[-]\n进入[FFFE0D] 四强 [-]",
    "[C8FF00]本月达成：[-]\n获得[FFFE0D] 新人王 [-]"
  },
  InDifferBattle = {
    "[C8FF00]本月达成任意一项：[-]\n获得[FFFE0D] 一般 [-]评价\n参加心魔幻境[FFFE0D] (%d/2) [-]",
    "[C8FF00]本月达成任意一项：[-]\n获得[FFFE0D] 良好 [-]评价\n参加心魔幻境[FFFE0D] (%d/4) [-]",
    "[C8FF00]本月达成任意一项：[-]\n获得[FFFE0D] 优秀 [-]评价\n参加心魔幻境[FFFE0D] (%d/8) [-]",
    "[C8FF00]本月达成：[-]\n获得[FFFE0D] 卓越 [-]评价",
    "[C8FF00]本月达成：[-]\n获得[FFFE0D] 最佳 [-]评价"
  },
  HuaShanLunJian = {
    "[C8FF00]本月达成任意一项：[-]\n获得前[FFFE0D] 256 [-]名\n参加华山论剑[FFFE0D] (%d/8) [-]",
    "[C8FF00]本月达成任意一项：[-]\n获得前[FFFE0D] 128 [-]名\n参加华山论剑[FFFE0D] (%d/16) [-]",
    "[C8FF00]本月达成任意一项：[-]\n获得前[FFFE0D] 64 [-]名\n参加华山论剑[FFFE0D] (%d/32) [-]",
    "[C8FF00]本月达成：[-]\n获得前[FFFE0D] 32 [-]名",
    "[C8FF00]本月达成：[-]\n获得前[FFFE0D] 8 [-]名"
  },
  QunYingHui = {
    "[C8FF00]本月达成任意一项：[-]\n单场获胜[FFFE0D] 2 [-]轮\n参加群英会[FFFE0D] (%d/2) [-]",
    "[C8FF00]本月达成任意一项：[-]\n单场获胜[FFFE0D] 3 [-]轮\n参加群英会[FFFE0D] (%d/3) [-]",
    "[C8FF00]本月达成任意一项：[-]\n单场获胜[FFFE0D] 4 [-]轮\n参加群英会[FFFE0D] (%d/4) [-]",
    "[C8FF00]本月达成：[-]\n单场获胜[FFFE0D] 5 [-]轮",
    "[C8FF00]本月达成：[-]\n单场[FFFE0D] 6 [-]轮全胜"
  }
}
function tbTip:OnOpenEnd(szKey)
  self.szKey = szKey
  self:Update()
  self:CloseTimer()
  self.nCloseTimerId = Timer:Register(Env.GAME_FPS * 50, function(self)
    self.nCloseTimerId = nil
    Ui:CloseWindow(self.UI_NAME)
  end, self)
end
function tbTip:Update()
  self.pPanel:SetActive("Rule", not self.bShowAward)
  self.pPanel:SetActive("Award", self.bShowAward or false)
  local tbInfo = tbUi.tbAthleticsAct[self.szKey]
  for i = 1, 5 do
    self.pPanel:Sprite_SetSprite("Icon" .. i, tbInfo.tbDivisionIcon[i])
  end
  if self.bShowAward then
    self:UpdateAward()
  else
    self:UpdateRule()
  end
end
function tbTip:UpdateRule()
  local tbDesc = self.tbDesc[self.szKey]
  local tbHonorInfo = Calendar.tbHonorInfo[self.szKey]
  local nJoinTimes = me.GetUserValue(Calendar.GROUP, tbHonorInfo.nJoinTimesKey)
  local nDivision = Calendar:GetDivision(me, self.szKey)
  for nIdx, szDesc in ipairs(tbDesc) do
    self.pPanel:SetActive("Describe" .. nIdx, nIdx >= nDivision)
    self.pPanel:SetActive("Current" .. nIdx, nIdx == nDivision)
    if nIdx >= nDivision then
      local szNewDesc = string.format(szDesc, nJoinTimes)
      self["Describe" .. nIdx]:SetLinkText(szNewDesc)
    end
  end
end
function tbTip:UpdateAward()
  local nDivision = Calendar:GetDivision(me, self.szKey)
  for i = 1, #Calendar.tbDivisionKey do
    self.pPanel:SetActive("ARank" .. i, i >= nDivision)
    self.pPanel:SetActive("Current" .. i, i == nDivision)
    if i >= nDivision then
      for j = 1, #Calendar.tbDivisionAward[i] do
        local szIF = string.format("itemframe%d_%d", i, j)
        local tbItemframe = self[szIF]
        tbItemframe:SetGenericItem(Calendar.tbDivisionAward[i][j])
        tbItemframe.fnClick = tbItemframe.DefaultClick
        self.pPanel:Label_SetText("Process" .. i, string.format("武林荣誉：%d", Calendar.DIVISION_HOUR[i]))
      end
    end
  end
end
function tbTip:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
function tbTip:OnClose()
  self:CloseTimer()
end
function tbTip:CloseTimer()
  if self.nCloseTimerId then
    Timer:Close(self.nCloseTimerId)
    self.nCloseTimerId = nil
  end
end
tbTip.tbOnClick = {
  BtnAward = function(self)
    self.bShowAward = true
    self:Update()
  end,
  BtnRule = function(self)
    self.bShowAward = false
    self:Update()
  end
}
local tbAni = Ui:CreateClass("AthleticsHonorAni")
function tbAni:OnOpenEnd(szKey, nDivision)
  local tbInfo = tbUi.tbAthleticsAct[szKey]
  self.pPanel:Sprite_SetSprite("Icon", tbInfo.tbDivisionIcon[nDivision])
  local szRank = string.format("UI/Textures/%s.png", tbUi.tbDivisionBg[nDivision])
  self.pPanel:Texture_SetTexture("RankIcon", szRank)
  self.pPanel:Label_SetText("Title", string.format("您的%s段位晋升为", tbInfo.szName))
  self.pPanel:Label_SetText("Rank", Calendar.tbDivisionName[nDivision])
  local tbNode = {
    "Icon",
    "Txt",
    "Title",
    "Rank",
    "RankUp",
    "badge1",
    "badge2_1",
    "badge2_2",
    "badge3_1",
    "badge3_2",
    "badge4_1",
    "badge4_2",
    "Light1",
    "Light2"
  }
  for _, szNode in ipairs(tbNode) do
    self.pPanel:Tween_Reset(szNode)
    self.pPanel:Tween_Play(szNode)
  end
  self.pPanel:SetActive("Label", false)
  local szShowTX
  for _, szTexiao in pairs(tbUi.tbTexiaoName) do
    if not Lib:IsEmptyStr(szTexiao) then
      self.pPanel:SetActive(szTexiao, false)
      if _ == nDivision then
        szShowTX = szTexiao
      end
    end
  end
  self:CloseTimer()
  self.nAniTimer = Timer:Register(Env.GAME_FPS * 6, self.ShowTexiao, self, szShowTX)
  self.nOpenTime = GetTime()
  function self.pPanel.OnTouchEvent()
    self:Touch2Close()
  end
end
function tbAni:ShowTexiao(szShowTX)
  if szShowTX then
    self.pPanel:SetActive(szShowTX, true)
  end
  self.nAniTimer = Timer:Register(Env.GAME_FPS * 2, self.ShowCloseTip, self)
end
function tbAni:ShowCloseTip()
  self.nAniTimer = nil
  self.pPanel:SetActive("Label", true)
end
function tbAni:OnClose()
  self:CloseTimer()
end
function tbAni:CloseTimer()
  if self.nAniTimer then
    Timer:Close(self.nAniTimer)
    self.nAniTimer = nil
  end
end
function tbAni:Touch2Close()
  if GetTime() - self.nOpenTime >= 8 then
    Ui:CloseWindow(self.UI_NAME)
  end
end
