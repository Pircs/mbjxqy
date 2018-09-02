SendBless.nMinLevel = 20
SendBless.nStackMax = 5
SendBless.nTimeStep = 1200
SendBless.nMAX_SEND_TIMES = 20
SendBless.TOP_NUM = 10
SendBless.COST_GOLD = 88
SendBless.nItemDelayDelteTime = 0
SendBless.szDefaultWord = "周年庆快乐"
SendBless.szWordMaxLen = 30
SendBless.tbActSetting = {
  [1] = {
    szActName = "SendBlessAct",
    szNotifyUi = "Lantern",
    szOpenUi = "BlessPanel",
    szNormalSprite = false,
    szGoldSprite = false,
    bRank = true,
    bGoldSkipTimes = false,
    nCardItemId = 3066,
    tbGetBlessAward = false,
    nMaxGetBlessAwardTimes = false,
    szItemUseName = "国庆祝福",
    szMailTitle = "普天同庆",
    szMailText = "少侠，江湖路远，您也结交了很多武林同道吧？值此国庆佳节，或许应该给他们送去诚挚的祝福，邀请他们一起欢度这个节日吧。这张“[FFFE0D]普天同庆祝福函[-]”可以帮你收集和送出祝福，请查收。详细内容请查阅[url=openwnd:最新消息, NewInformationPanel, 'SendBlessAct']相关页面。",
    szGetBlessMsgNormal = "恭喜您获得了来自好友「%s」的国庆祝福！",
    szGetBlessMsgGold = "大惊喜！获得来自好友「%s」的特别国庆祝福",
    szSendBlessMsg = "您向好友「%s」送出了国庆的祝福！",
    szColorSendMsg = false,
    szNewsTitle = "国庆·普天同庆",
    szNewsText = "        [FFFE0D]新一轮国庆“普天同庆”祝福活动开始了！[-]\n\n            通过祝福道具给好友送出祝福，根据总祝福值领取档次奖励，并参与排行获得永久称号。活动共开启[FFFE0D]3轮[-]，分别在10月[FFFE0D]20、22、25[-]日0点开始，[FFFE0D]下一天4点[-]结束。\n        [FFFE0D]本轮活动时间：[-]%s\n        [FFFE0D]参与等级：[-]20级\n\n        [FFFE0D]1、祝福函[-]\n            活动开启后，满足条件的玩家能收到一封系统邮件，查收附件可得到[11adf6][url=openwnd:普天同庆祝福函, ItemTips, \"Item\", nil, 3066][-]。\n            在祝福界面可对好友送出祝福，对方能获得[FFFE0D]祝福值[-]。根据条件不同（如祝福方头衔、双方亲密等级、家族及师徒关系等）能获得[FFFE0D]额外祝福值[-]，进行[FFFE0D]元宝祝福[-]也能额外获得祝福值。\n            祝福函中从好友处获得的祝福值前[FFFE0D]10[-]名相加，为大侠自己获得的[FFFE0D]总祝福值[-]。\n            每轮活动开始时，会清空祝福值并重置祝福状态。\n        [FFFE0D]2、祝福次数[-]\n            向好友送祝福需要消耗祝福次数，每[FFFE0D]20[-]分钟可以获得[FFFE0D]1[-]祝福次数，累计上限为[FFFE0D]5[-]。\n            [FFFE0D]每轮[-]活动，每位侠客最多向[FFFE0D]20[-]名好友送出祝福，对同一好友最多祝福1次。\n        [FFFE0D]3、活动奖励[-]\n            随着祝福函中的总祝福值越来越大，可以领取[FFFE0D]档次奖励[-]，如下：\n            ·达到5：  可领取2个[11adf6][url=openwnd:黄金宝箱, ItemTips, \"Item\", nil, 786][-]\n            ·达到10： 可领取1000贡献\n            ·达到20： 可领取2个[11adf6][url=openwnd:蓝水晶, ItemTips, \"Item\", nil, 223][-]\n            ·达到30： 可领取200元宝\n            ·达到40： 可领取3000贡献\n            ·达到50： 可领取[11adf6][url=openwnd:3级魂石箱, ItemTips, \"Item\", nil, 2164][-]\n            ·达到60： 可领取[11adf6][url=openwnd:高级藏宝图, ItemTips, \"Item\", nil, 788][-]\n            ·达到70： 可领取[11adf6][url=openwnd:紫水晶, ItemTips, \"Item\", nil, 224][-]\n            ·达到80： 可领取500元宝\n            ·达到90： 可领取5000贡献\n            ·达到100：可领取[11adf6][url=openwnd:4级魂石箱, ItemTips, \"Item\", nil, 2165][-]\n\n        [FFFE0D]每轮[-]活动会在“排行榜”中对玩家的总祝福值进行排名，结束时按照排名获得[FFFE0D]永久称号[-]：\n            ·第1名：    橙色称号“挚友如云”\n            ·第2~10名： 粉色称号“高朋满座”\n            ·第11~30名：紫色称号“门庭若市”\n        "
  },
  [2] = {
    szActName = "SendBlessActWord",
    szNotifyUi = "NewYear",
    szNormalSprite = "NewYear01",
    szGoldSprite = "NewYear02",
    szOpenUi = "BlessPanelWord",
    bRank = false,
    bGoldSkipTimes = true,
    nCardItemId = 3687,
    tbGetBlessAward = {
      {
        "item",
        3712,
        1
      }
    },
    nMaxGetBlessAwardTimes = 10,
    szItemUseName = "周年庆祝福",
    szMailTitle = "周年庆祝福",
    szMailText = "少侠，江湖路远，您也结交了很多武林同道吧？值此周年庆典，或许应该给他们送去诚挚的祝福，邀请他们一起欢度这个庆典吧。这张“[FFFE0D]周年庆祝福函[-]”可以帮你收集和送出祝福，请查收。详细内容请查阅[url=openwnd:最新消息, NewInformationPanel, 'SendBlessActWord']相关页面。",
    szGetBlessMsgNormal = "恭喜您获得了来自好友「%s」的周年庆祝福！",
    szGetBlessMsgGold = "大惊喜！获得来自好友「%s」的特别周年庆祝福",
    szSendBlessMsg = "您向好友「%s」送出了周年庆的祝福！",
    szColorSendMsg = "侠士「%s」向其好友「%s」发送了周年庆祝福：%s",
    szNewsTitle = "周年庆祝福",
    szNewsText = "        [FFFE0D]新一轮周年庆祝福活动开始了！[-]\n\n        通过祝福道具给好友送出祝福并获得奖励。活动共开启[FFFE0D]3轮[-]，分别在[FFFE0D]10月20日、10月22日、10月25日[-]0点开始，[FFFE0D]下一天4点[-]结束。\n        [FFFE0D]本轮活动时间：[-]%s\n        [FFFE0D]参与等级：[-]20级\n\n            活动开启后，满足条件的玩家能收到一封系统邮件，查收附件可得到[11adf6][url=openwnd:周年庆祝福函, ItemTips, \"Item\", nil, 3687][-]。\n            使用祝福函后，在祝福界面可对好友送出祝福，同时对方能获得[FFFE0D]祝福宝箱[-]。每轮活动，每个玩家最多获得[FFFE0D]10个[-]祝福宝箱。\n            每轮活动，每位侠客最多向[FFFE0D]20名[-]好友送出祝福，对同一好友最多祝福1次。消耗元宝祝福不会消耗祝福次数。\n            可能获得奖励：[11adf6][url=openwnd:修炼丹, ItemTips, \"Item\", nil, 2301][-]，[11adf6][url=openwnd:传功丹, ItemTips, \"Item\", nil, 2759][-]，[11adf6][url=openwnd:外装染色剂, ItemTips, \"Item\", nil, 2569][-]，[11adf6][url=openwnd:紫水晶, ItemTips, \"Item\", nil, 224][-]。\n        "
  }
}
SendBless.tbHonorScore = {
  [6] = 1,
  [7] = 2,
  [8] = 3,
  [9] = 4,
  [10] = 5
}
SendBless.tbImityScore = {
  {5, 1},
  {10, 2},
  {15, 3},
  {20, 4},
  {30, 5}
}
SendBless.tbRankAward = {
  {
    nRankEnd = 1,
    tbAward = {
      "AddTimeTitle",
      408,
      -1
    }
  },
  {
    nRankEnd = 10,
    tbAward = {
      "AddTimeTitle",
      407,
      -1
    }
  },
  {
    nRankEnd = 30,
    tbAward = {
      "AddTimeTitle",
      406,
      -1
    }
  }
}
SendBless.tbTakeAwardSet = {
  {
    nScore = 5,
    tbAward = {
      "item",
      786,
      2
    }
  },
  {
    nScore = 10,
    tbAward = {"Contrib", 1000}
  },
  {
    nScore = 20,
    tbAward = {
      "item",
      223,
      2
    }
  },
  {
    nScore = 30,
    tbAward = {"Gold", 200}
  },
  {
    nScore = 40,
    tbAward = {"Contrib", 3000}
  },
  {
    nScore = 50,
    tbAward = {
      "item",
      2164,
      1
    }
  },
  {
    nScore = 60,
    tbAward = {
      "item",
      788,
      1
    }
  },
  {
    nScore = 70,
    tbAward = {
      "item",
      224,
      1
    }
  },
  {
    nScore = 80,
    tbAward = {"Gold", 500}
  },
  {
    nScore = 90,
    tbAward = {"Contrib", 5000}
  },
  {
    nScore = 100,
    tbAward = {
      "item",
      2165,
      1
    }
  }
}
SendBless.SAVE_GROUP = 116
SendBless.KEY_RESET_DAY = 1
SendBless.KEY_SEND_TIME = 2
SendBless.KEY_CUR_SEND_TIMES = 3
SendBless.KEY_TakeAwardLevel = 4
function SendBless:GetNowMaxSendTimes(pPlayer)
  local nLastSendTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_SEND_TIME)
  if nLastSendTime == 0 then
    return self.nStackMax
  end
  local nTimeDiff = GetTime() - nLastSendTime
  local nNowSaveCur = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_CUR_SEND_TIMES)
  return math.min(nNowSaveCur + math.floor(nTimeDiff / self.nTimeStep), self.nStackMax), nTimeDiff
end
function SendBless:GetScoreInfo(tbData)
  if not tbData then
    return 0
  end
  local tbSort = {}
  for dwRoleId, nVal in pairs(tbData) do
    table.insert(tbSort, nVal)
  end
  table.sort(tbSort, function(a, b)
    return b < a
  end)
  local nTotalVal = 0
  for i = 1, self.TOP_NUM do
    if tbSort[i] then
      nTotalVal = nTotalVal + tbSort[i]
    else
      break
    end
  end
  return nTotalVal
end
function SendBless:GetSendTimes(tbSendData, bGoldSkipTimes)
  local nCount = 0
  for k, v in pairs(tbSendData) do
    if not bGoldSkipTimes or v ~= 2 then
      nCount = nCount + 1
    end
  end
  return nCount
end
function SendBless:CheckSendCondition(pPlayer, dwRoleId2, tbData, bUseGold)
  if pPlayer.nLevel < self.nMinLevel then
    pPlayer.CenterMsg("等级不足")
    return
  end
  if tbData[dwRoleId2] then
    pPlayer.CenterMsg("已经赠送过了")
    return
  end
  local tbActSetting = self:GetActSetting()
  if not tbActSetting.bGoldSkipTimes or not bUseGold then
    if not pPlayer.nSendBlessTimes then
      pPlayer.nSendBlessTimes = self:GetSendTimes(tbData, tbActSetting.bGoldSkipTimes)
    end
    if pPlayer.nSendBlessTimes >= self.nMAX_SEND_TIMES then
      pPlayer.CenterMsg(string.format("每天最多赠送%d次", self.nMAX_SEND_TIMES))
      return
    end
  end
  if tbActSetting.bRank then
    local nCurHasCount = SendBless:GetNowMaxSendTimes(pPlayer)
    if nCurHasCount <= 0 then
      pPlayer.CenterMsg("您当前可用祝福次数不足")
      return
    end
  end
  local bInProcess = Activity:__IsActInProcessByType(tbActSetting.szActName)
  if not bInProcess then
    pPlayer.CenterMsg("本轮活动已经结束")
    return
  end
  return true, nCurHasCount
end
function SendBless:GetSendBlessVal(dwRoleId1, dwRoleId2, pRole1, pRole2)
  local nScore = 1
  local tbActSetting = self:GetActSetting()
  if not tbActSetting.bRank then
    return nScore
  end
  local nFriendLevel = FriendShip:GetFriendImityLevel(dwRoleId1, dwRoleId2)
  local nAddScore = 0
  for i, v in ipairs(self.tbImityScore) do
    if nFriendLevel >= v[1] then
      nAddScore = v[2]
    else
      break
    end
  end
  nScore = nScore + nAddScore
  local nSenderHonorLevel = pRole1.nHonorLevel
  nScore = nScore + (self.tbHonorScore[nSenderHonorLevel] or 0)
  if pRole1.dwKinId ~= 0 and pRole1.dwKinId == pRole2.dwKinId then
    nScore = nScore + 1
  end
  if TeacherStudent:_IsConnected(pRole1, pRole2) then
    nScore = nScore + 1
  end
  return nScore
end
function SendBless:GetCurAwardLevel(pPlayer, tbGet)
  local nHasTakedLevel = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TakeAwardLevel)
  local nNewLevel = nHasTakedLevel + 1
  local tbAwardInfo = self.tbTakeAwardSet[nNewLevel]
  if not tbAwardInfo then
    return
  end
  local nTotalVal = SendBless:GetScoreInfo(tbGet)
  if nTotalVal < tbAwardInfo.nScore then
    return
  end
  return nNewLevel, tbAwardInfo.tbAward
end
function SendBless:GetActSetting()
  if self.TryGetCurType then
    self:TryGetCurType()
  end
  return SendBless.tbActSetting[self.nType]
end
