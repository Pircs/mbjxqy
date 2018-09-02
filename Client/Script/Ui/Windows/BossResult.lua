local tbUi = Ui:CreateClass("BossResult")
function tbUi:OnOpen(tbMyRank, tbMyKinRank, tbPlayerRank, tbKinRank)
  self.tbPlayerRank = tbPlayerRank
  self.tbKinRank = tbKinRank
  self.tbMyRank = tbMyRank
  self.tbMyKinRank = tbMyKinRank
  self:UpdatePlayerRank()
end
local tbNumToStr = {
  "一",
  "二",
  "三",
  "四",
  "五",
  "六",
  "七",
  "八",
  "九",
  "十"
}
function tbUi:UpdatePlayerRank()
  self.pPanel:SetActive("PlayerNode", true)
  self.pPanel:SetActive("KinNode", false)
  local tbItems = self.tbPlayerRank
  local function fnSetItem(itemObj, nIdx)
    local tbItem = tbItems[nIdx]
    itemObj.pPanel:SetActive("KinItem", false)
    itemObj.pPanel:SetActive("PlayerItem", true)
    itemObj = itemObj.MyResult
    itemObj.pPanel:Label_SetText("PlayerName", tbItem.szName)
    itemObj.pPanel:Label_SetText("TxtPoint", math.floor(tbItem.nScore))
    itemObj.pPanel:Label_SetText("TxtKinName", tbItem.szKinName or "")
    local tbHonorInfo = Player.tbHonorLevelSetting[tbItem.nHonorLevel]
    if tbHonorInfo and tbHonorInfo.ImgPrefix then
      itemObj.pPanel:SetActive("PlayerTitle", true)
      itemObj.pPanel:Sprite_Animation("PlayerTitle", tbHonorInfo.ImgPrefix)
    else
      itemObj.pPanel:SetActive("PlayerTitle", false)
    end
    itemObj.pPanel:Sprite_SetSprite("Faction", Faction:GetIcon(tbItem.nFaction))
    self:SetRank(itemObj, nIdx)
  end
  self.ScrollView:Update(#tbItems, fnSetItem)
  local nMyRank = self.tbMyRank.nRank
  local nScore = self.tbMyRank.nScore
  local myRankObj = self.MyResult
  self:SetRank(myRankObj, nMyRank)
  myRankObj.pPanel:Label_SetText("PlayerName", me.szName)
  myRankObj.pPanel:Label_SetText("TxtPoint", nScore)
  myRankObj.pPanel:Sprite_SetSprite("Faction", Faction:GetIcon(me.nFaction))
  myRankObj.pPanel:Label_SetText("TxtKinName", self.tbMyKinRank and self.tbMyKinRank.szName or "")
  local tbHonorInfo = Player.tbHonorLevelSetting[me.nHonorLevel]
  if tbHonorInfo and tbHonorInfo.ImgPrefix then
    myRankObj.pPanel:SetActive("PlayerTitle", true)
    myRankObj.pPanel:Sprite_Animation("PlayerTitle", tbHonorInfo.ImgPrefix)
  else
    myRankObj.pPanel:SetActive("PlayerTitle", false)
  end
end
local GetKinRewardTxt = function(nIth)
  local tbKinRewardSetting = Boss.Def.tbKinBoxRankScore[1]
  for _, tbItem in ipairs(Boss.Def.tbKinBoxRankScore) do
    if nIth <= tbItem.Rank then
      tbKinRewardSetting = tbItem
      break
    end
  end
  local _, szIcon = Shop:GetMoneyName(Boss.Def.szAwardMoneyType)
  return szIcon .. " " .. tbKinRewardSetting.Honor
end
function tbUi:UpdateKinRank()
  self.pPanel:SetActive("PlayerNode", false)
  self.pPanel:SetActive("KinNode", true)
  local tbItems = self.tbKinRank
  local function fnSetItem(itemObj, nIdx)
    local tbItem = tbItems[nIdx]
    itemObj.pPanel:SetActive("KinItem", true)
    itemObj.pPanel:SetActive("PlayerItem", false)
    itemObj = itemObj.MyKinResult
    itemObj.pPanel:Label_SetText("KinName", tbItem.szName)
    itemObj.pPanel:Label_SetText("TxtKinPoint", math.floor(tbItem.nScore))
    itemObj.pPanel:Label_SetText("TxtKinAward", GetKinRewardTxt(nIdx))
    itemObj.pPanel:Label_SetText("TxtKinParticipant", tbItem.nJoinMember == 0 and 1 or tbItem.nJoinMember)
    self:SetRank(itemObj, nIdx)
  end
  self.ScrollViewKin:Update(#tbItems, fnSetItem)
  self.pPanel:SetActive("MyKinResult", Kin:HasKin())
  if not Kin:HasKin() or not next(self.tbMyKinRank or {}) then
    return
  end
  local tbMyKinRank = self.tbMyKinRank
  local kinRankObj = self.MyKinResult
  self:SetRank(kinRankObj, tbMyKinRank.nRank)
  kinRankObj.pPanel:Label_SetText("KinName", tbMyKinRank.szName)
  kinRankObj.pPanel:Label_SetText("TxtKinPoint", math.floor(tbMyKinRank.nScore))
  kinRankObj.pPanel:Label_SetText("TxtKinParticipant", tbMyKinRank.nJoinMember == 0 and 1 or tbMyKinRank.nJoinMember)
  kinRankObj.pPanel:Label_SetText("TxtKinAward", GetKinRewardTxt(tbMyKinRank.nRank))
end
function tbUi:SetRank(itemObj, nRank)
  if nRank <= 3 then
    itemObj.pPanel:SetActive("NO123", true)
    itemObj.pPanel:SetActive("Rank", false)
    for i = 1, 3 do
      itemObj.pPanel:SetActive("NO" .. i, i == nRank)
    end
  else
    local szRank = string.format("第%s名", tbNumToStr[nRank] or nRank)
    itemObj.pPanel:Label_SetText("Rank", szRank)
    itemObj.pPanel:SetActive("NO123", false)
    itemObj.pPanel:SetActive("Rank", true)
  end
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnPlayerRank()
  self:UpdatePlayerRank()
end
function tbUi.tbOnClick:BtnKinRank()
  self:UpdateKinRank()
end
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
  Ui:CloseWindow("BossPanel")
end
function tbUi.tbOnClick:BtnToMail()
  Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelMail)
  Ui:CloseWindow(self.UI_NAME)
  Ui:CloseWindow("BossPanel")
end
