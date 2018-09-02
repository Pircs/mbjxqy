local tbUi = Ui:CreateClass("MainShowOffPanel")
function tbUi:OnOpen()
  if Sdk:IsLoginByGuest() then
    me.CenterMsg("暂时无法进行分享")
    return 0
  end
end
function tbUi:OnOpenEnd(szShowOffType, ...)
  self.szShowOffType = szShowOffType
  self:UpdateUserInfo(szShowOffType, ...)
  self:SetButtonState(true)
  if Sdk:IsMsdk() then
    local bLoginByQQ = Sdk:IsLoginByQQ()
    self.pPanel:Label_SetText("TxtShareFriend", bLoginByQQ and "分享给QQ好友" or "分享给微信好友")
    self.pPanel:Label_SetText("TxtShareCircle", bLoginByQQ and "分享到QQ空间" or "分享到朋友圈")
  elseif Sdk:IsEfunHKTW() or version_xm then
    self.pPanel:Label_SetText("TxtShareCircle", "分享到Facebook")
  end
end
function tbUi:UpdateUserInfo(szShowOffType, tbExtraInfo)
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  self.pPanel:SetActive("HSLJ", "HSLJ" == szShowOffType)
  self.pPanel:SetActive("MainCity", "MainCity" == szShowOffType)
  self.pPanel:SetActive("Faction", "Faction" == szShowOffType)
  if szShowOffType == "HSLJ" then
    local tbHSLJInfo = tbExtraInfo or {}
    self.pPanel:Label_SetText("TeamName", tbHSLJInfo.szName or "")
    local szTeamMates = ""
    for _, tbShowInfo in pairs(tbHSLJInfo.tbAllPlayer or {}) do
      szTeamMates = string.format([[
%s
%s]], szTeamMates, tbShowInfo.szName or "")
    end
    self.pPanel:Label_SetText("MemberName", szTeamMates)
  end
  self.pPanel:Label_SetText("NameTxt", me.szName)
  self.pPanel:NpcView_Open("PartnerView")
  local tbNpcRes, tbEffectRes = me.GetNpcResInfo()
  local tbFactionScale = {
    0.92,
    1,
    1.15,
    1
  }
  local fScale = tbFactionScale[me.nFaction] or 1
  for nPartId, nResId in pairs(tbNpcRes) do
    local nCurResId = nResId
    if nPartId == Npc.NpcResPartsDef.npc_part_horse then
      nCurResId = 0
    end
    self.pPanel:NpcView_ChangePartRes("PartnerView", nPartId, nCurResId)
  end
  for nPartId, nResId in pairs(tbEffectRes) do
    self.pPanel:NpcView_ChangePartEffect("PartnerView", nPartId, nResId)
  end
  self.pPanel:NpcView_SetScale("PartnerView", fScale)
end
tbUi.tbOnDrag = {
  PartnerView = function(self, szWnd, nX, nY)
    self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
  end
}
function tbUi:OnClose()
  self.pPanel:NpcView_Close("PartnerView")
end
function tbUi:SetButtonState(bShow)
  self.pPanel:SetActive("BtnShareFriend", bShow and Sdk:IsMsdk())
  self.pPanel:SetActive("BtnShareCircle", bShow)
  self.pPanel:SetActive("BtnClose", bShow)
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnShareFriend()
  local szType = Sdk:IsLoginByQQ() and "QQ" or "WX"
  if not Sdk:CheckShareType(szType) then
    return
  end
  self:SetButtonState(false)
  UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO)
  Sdk:TlogShare(self.szShowOffType)
  Timer:Register(3, function()
    Sdk:SharePhoto(szType, self.szShareTag or "MSG_SHARE_FRIEND_HIGH_SCORE")
  end)
  Timer:Register(7, function()
    Ui:CloseWindow(self.UI_NAME)
  end)
end
function tbUi.tbOnClick:BtnShareCircle()
  if Sdk:IsMsdk() then
    do
      local szType = Sdk:IsLoginByQQ() and "QZone" or "WXMo"
      if not Sdk:CheckShareType(szType) then
        return
      end
      self:SetButtonState(false)
      UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO)
      Sdk:TlogShare(self.szShowOffType)
      Timer:Register(3, function()
        Sdk:SharePhoto(szType, self.szShareTag or "MSG_SHARE_MOMENT_HIGH_SCORE")
      end)
    end
  elseif Sdk:IsEfunHKTW() then
    do
      local szHKUrl = "http://ad.efuntw.com/ads_download.shtml?advertiser=efunactivity1&gameCode=hkjxqy&adsid=efunactivity1_hkjxqy_hk_2_qrcode_by002"
      local szTWUrl = "http://ad.efuntw.com/ads_download.shtml?advertiser=efunactivity1&gameCode=twjxqy&adsid=efunactivity1_twjxqy_tw_2_qrcode_by002"
      self:SetButtonState(false)
      UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO)
      Timer:Register(3, function()
        Sdk:XGSharePhoto("剑侠情缘手游", "", "二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！", "二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！", version_hk and szHKUrl or szTWUrl)
      end)
    end
  elseif version_xm then
    self:SetButtonState(false)
    UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO)
    Timer:Register(3, function()
      Sdk:XGSharePhoto("剑侠情缘手游", "", "二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！", "二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！", "https://www.facebook.com/252128865154649")
    end)
  end
  Timer:Register(7, function()
    Ui:CloseWindow(self.UI_NAME)
  end)
end
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
