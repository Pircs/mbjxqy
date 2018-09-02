local SdkMgr = luanet.import_type("SdkInterface")
local TssSdkEntryId = {
  ENTRY_ID_QZONE = 1,
  ENTRY_ID_MM = 2,
  ENTRY_ID_OTHERS = 3
}
Sdk.OPEN_GSKD = true
Sdk.OPEN_REPORT_DATA = true
function Sdk:Available()
  if WINDOWS then
    return false
  end
  if Ui.FTDebug.bDebug then
    if Ui.FTDebug.bSkipSdk then
      return false
    end
  elseif Login.ClientSet.Sdk and Login.ClientSet.Sdk.Skip then
    return false
  end
  return true
end
function Sdk:OnRoleCreate(nCode, nRoleID)
  if nCode ~= 0 then
    return
  end
  if Sdk:IsXgSdk() then
    self.nCurCreateRoleId = nRoleID
  end
end
function Sdk:OnLogin(bReconnect)
  if Sdk:IsMsdk() then
    if not Sdk:CheckOpenId() then
      return
    end
    Sdk:MidasInit()
    Sdk:UploadMsdkInfo(not bReconnect)
    Sdk:ReportGameCenterPlat()
    Sdk:ReprotASMInfo()
  end
  local tbPlatFriendData = Client:GetDirFileData("PlatFriend" .. Sdk:GetUid())
  tbPlatFriendData.tbGiftInfo = nil
  Sdk:XGOnLogin(bReconnect)
end
function Sdk:OnClientStart()
  if Sdk:IsOuterChannel() and Sdk:IsMsdk() and SetNpcForbidTitle then
    SetNpcForbidTitle(Sdk.Def.nWeixinTitleId, true)
    SetNpcForbidTitle(Sdk.Def.nQQVipTitleId, true)
  end
  Sdk:QueryASMInfo()
  Sdk:XGSetVersionProperties()
end
function Sdk:Login(nPlatform, bForIOSServer)
  if not Login:AllowLogin() then
    return
  end
  local nNow = GetTime()
  if self.nNextLoginTime and nNow < self.nNextLoginTime then
    return
  end
  self.nNextLoginTime = nNow + 13
  if bForIOSServer then
    Client:SetFlag("ForIOSServer", true, -1)
  else
    Client:ClearFlag("ForIOSServer", -1)
  end
  if Sdk:IsXgSdk() then
    Sdk:XGLogin("")
  elseif Sdk:IsMsdk() then
    if nPlatform == Sdk.ePlatform_Weixin and not Sdk:IsPlatformInstalled(nPlatform) then
      if IOS then
        me.CenterMsg("您尚未安装微信")
      else
        SdkMgr.QrLogin(nPlatform)
      end
      return
    end
    SdkMgr.Login(nPlatform or Sdk.ePlatform_QQ)
  end
end
function Sdk:IsPlatformInstalled(nPlatform)
  return SdkMgr.IsPlatformInstalled(nPlatform)
end
function Sdk:LoginWithLocalInfo()
  if not Login:AllowLogin() then
    return
  end
  if Sdk:Available() then
    if Sdk:IsMsdk() then
      SdkMgr.Login(Sdk.ePlatform_None)
    end
    if Sdk:IsXgSdk() then
      Sdk:XGLogin("")
    end
  end
end
function Sdk:Logout(bClearWakeupInfo)
  if bClearWakeupInfo then
    Sdk:ClearWakeupInfo()
  end
  self.nCurPlatform = nil
  self.nNextLoginTime = nil
  self.szXGEfunFacebookId = nil
  Recharge.nLastTotalRechare = nil
  if Sdk:IsMsdk() then
    SdkMgr.Logout()
  elseif Sdk:IsXgSdk() then
    Sdk:XGLogout("")
  end
end
function Sdk:ClearWakeupInfo()
  if Sdk:IsMsdk() then
    SdkMgr.s_nWakeupPlat = Sdk.ePlatform_None
    SdkMgr.s_szCurLaunchOpenId = ""
  end
end
function Sdk:ShowNotice()
  local szScene = "1"
  Log("Sdk:ShowNotice", szScene)
  SdkMgr.ShowNotice(szScene)
end
function Sdk:GetNoticeData()
  if Sdk:IsMsdk() then
    local szScene = "1"
    return SdkMgr.GetNoticeData(szScene)
  end
end
local Application = luanet.import_type("UnityEngine.Application")
function Sdk:OpenUrl(szUrl, nDir)
  Log("Sdk:OpenUrl:", szUrl)
  if WINDOWS then
    Application.OpenUrl(szUrl)
    return
  end
  if Sdk:IsMsdk() then
    SdkMgr.OpenUrl(szUrl, nDir or 0)
  elseif version_xm then
    if IOS then
      szUrl = Lib:EncodeJson({targetUrl = szUrl})
    end
    Sdk:CallXGMethod("openWebView", szUrl)
  else
    Application.OpenURL(szUrl)
  end
end
function Sdk:OpenUrlByOutsideWeb(szUrl)
  Application.OpenUrl(szUrl)
end
function Sdk:QueryFriendsInfo()
  local tbPlatFriendData = Client:GetDirFileData("PlatFriend" .. Sdk:GetUid())
  local nNow = GetTime()
  if tbPlatFriendData.nExpireTime and nNow < tbPlatFriendData.nExpireTime then
    FriendShip:SetPlatFriendsInfo(tbPlatFriendData.tbFriendsInfo or {})
    return
  end
  tbPlatFriendData.nExpireTime = nNow + 14400
  FriendShip:SetPlatFriendsInfo({})
  if Sdk:IsMsdk() then
    SdkMgr.QueryFriendsInfo(self.nCurPlatform or Sdk.ePlatform_QQ)
    SdkMgr.QueryMyInfo(self.nCurPlatform or Sdk.ePlatform_QQ)
  end
  if Sdk:HasEfunRank() then
    Sdk:XGGetUserFBProfile()
  end
end
function Sdk:Exit()
  if Ui.bIsForbiddenOperation or Ui:WindowVisible("SituationalDialogue") then
    return
  end
  local function fnExit()
    SdkMgr.QuitApplication()
  end
  Ui:OpenWindow("MessageBox", "是否退出游戏", {
    {fnExit},
    {}
  }, {"确定", "取消"})
end
function Sdk:GetUid()
  return GetAccountName()
end
function Sdk:GetChannelId()
  if self.szCurOutChannelId then
    return self.szCurOutChannelId
  end
  self.szCurOutChannelId = Client:GetLocalFileContent("/MyChannel.txt", Ui.ToolFunction.LibarayPath) or XG_CHANNEL_ID
  return self.szCurOutChannelId
end
function Sdk:GetLoginChannelId()
  return Sdk:IsMsdk() and tonumber(SdkMgr.GetChannelId()) or 0
end
function Sdk:GetRegisterChannelId()
  return Sdk:IsMsdk() and tonumber(SdkMgr.GetRegiterChannelId()) or 0
end
function Sdk:GetAssistChannelId()
  return Client:GetLocalFileContent("AssistChannel.txt")
end
function Sdk:SetServerPfInfo(szPf, szPfKey)
  self.szServerPf = szPf
  self.szServerPfKey = szPfKey
end
function Sdk:HasServerPfInfo()
  return self.szServerPf and self.szServerPfKey
end
function Sdk:GetMsdkInfo()
  if not Sdk:IsMsdk() then
    return {}
  end
  return {
    nOsType = Sdk:GetOsType(),
    nPlatform = SdkMgr.GetPlatform(),
    szOpenId = Sdk:GetUid(),
    szOpenKey = SdkMgr.GetAccessOpenKey(),
    szPayOpenKey = SdkMgr.GetPayOpenKey(),
    szPayToken = SdkMgr.GetPayToken(),
    szSessionId = SdkMgr.GetSessionId(),
    szSessionType = SdkMgr.GetSessionType(),
    szPf = self.szServerPf or SdkMgr.MidasGetPf(),
    szPfKey = self.szServerPfKey or SdkMgr.MidasGetPfKey(),
    bPCVersion = Sdk:IsPCVersion(),
    szLoginChannel = Sdk:GetChannelId(),
    szRegisterChannel = SdkMgr.GetRegiterChannelId()
  }
end
function Sdk:GetMsdkInfoStr()
  return Lib:EncodeJson(Sdk:GetMsdkInfo())
end
function Sdk:IsPCVersion()
  return ANDROID and Sdk.tbPCVersionChannels[Sdk:GetChannelId()]
end
function Sdk:IsLoginForIOS()
  return self.bForIOSServer and Sdk:IsPCVersion()
end
function Sdk:GetCurOfferId()
  if IOS or Sdk:IsLoginForIOS() then
    return Sdk.sziOSOfferId
  elseif ANDROID then
    return Sdk.szAndroidOfferId
  end
  return ""
end
function Sdk:GetLoginExtraInfo()
  if Sdk:IsLoginForIOS() then
    local szOfferId = Sdk:GetCurOfferId()
    if Sdk:IsLoginByQQ() then
      szOfferId = string.format("%s|%s", szOfferId, SdkMgr.GetPayToken())
    end
    return true, SdkMgr.GetRegiterChannelId(), Sdk:GetChannelId(), szOfferId
  else
    return false, "", "", ""
  end
end
function Sdk:GetOsType()
  if IOS or Sdk:IsLoginForIOS() then
    return Sdk.eOSType_iOS
  elseif ANDROID then
    return Sdk.eOSType_Android
  elseif WINDOWS then
    return Sdk.eOSType_Windows
  end
end
function Sdk:MidasInit()
  local tbMsdkInfo = Sdk:GetMsdkInfo()
  local function AndroidMidasInit()
    SdkMgr.MidasInit(Sdk:IsTest(), Sdk.szAndroidOfferId, Sdk:GetUid(), tbMsdkInfo.szPayOpenKey, tbMsdkInfo.szSessionId, tbMsdkInfo.szSessionType, tbMsdkInfo.szPf, tbMsdkInfo.szPfKey)
  end
  local function iOSMidasInit()
    local nServerId = Env.nOrgServerId
    if not nServerId or nServerId <= 0 then
      RemoteServer.SdkRequest("AskOrgServerIdForInit")
      assert(false)
      return
    end
    if Sdk:IsTest() and Sdk:IsMsdk() then
      nServerId = nServerId + 50000
    end
    SdkMgr.MidasRegisterPay(Sdk.sziOSOfferId, Sdk:GetUid(), tbMsdkInfo.szOpenKey, tbMsdkInfo.szSessionId, tbMsdkInfo.szSessionType, tbMsdkInfo.szPf, tbMsdkInfo.szPfKey, Sdk:IsTest() and "test" or "release", "", tostring(nServerId))
  end
  if ANDROID then
    Lib:CallBack({AndroidMidasInit})
  elseif IOS then
    Lib:CallBack({iOSMidasInit})
  end
end
function Sdk:CheckPayCondition()
  if Sdk:IsPCVersion() then
    me.CenterMsg("请使用游戏手机客户端进行购买支付操作")
    return
  end
  local nNow = GetTime()
  if self.nNextPayTime and nNow < self.nNextPayTime then
    me.CenterMsg(string.format("支付操作过于频繁, 请于%d秒后再试", self.nNextPayTime - nNow))
    return false
  end
  self.nNextPayTime = nNow + 60
  return true
end
function Sdk:Pay(nAmount, szProductId, tbRepartParam)
  if not Sdk:CheckPayCondition() then
    return
  end
  self.tbRepartParam = tbRepartParam
  RemoteServer.SdkRequest("PayReq", "Sdk:RealPay", nAmount, szProductId)
end
function Sdk:RealPay(szAcc, szPayUid, nAmount, szProductId)
  self.bIsPayingQQVip = nil
  self.szLastPayType = nil
  SdkMgr.SetReportTime()
  Log("Sdk:Pay", nAmount, szProductId, szAcc, szPayUid)
  if IOS then
    Sdk:iOSPay(szProductId, nAmount, true, szAcc, szPayUid)
  else
    local tbMsdkInfo = Sdk:GetMsdkInfo()
    local szAmount = tostring(nAmount)
    SdkMgr.MidasPay(Sdk.szAndroidOfferId, szAcc, tbMsdkInfo.szPayOpenKey, tbMsdkInfo.szSessionId, tbMsdkInfo.szSessionType, tbMsdkInfo.szPf, tbMsdkInfo.szPfKey, szAmount, szPayUid)
  end
end
function Sdk:PayCard(szServiceCode, szServiceName, szProductId, nLastingDay, tbRepartParam)
  if not Sdk:CheckPayCondition() then
    return
  end
  self.tbRepartParam = tbRepartParam
  RemoteServer.SdkRequest("PayReq", "Sdk:RealPayCard", szServiceCode, szServiceName, szProductId, nLastingDay)
end
function Sdk:RealPayCard(szAcc, szPayUid, szServiceCode, szServiceName, szProductId, nLastingDay)
  self.bIsPayingQQVip = nil
  self.szLastPayType = nil
  self.tbRepartParam = tbRepartParam
  SdkMgr.SetReportTime()
  Log("Sdk:PayCard", szServiceCode, szServiceName, szProductId, szAcc, szPayUid)
  if IOS then
    Sdk:iOSPay(szProductId, nLastingDay, false, szAcc, szPayUid)
  else
    local tbMsdkInfo = Sdk:GetMsdkInfo()
    SdkMgr.MidasPaySubscribe(Sdk.szAndroidOfferId, szAcc, tbMsdkInfo.szPayOpenKey, tbMsdkInfo.szSessionId, tbMsdkInfo.szSessionType, tbMsdkInfo.szPf, tbMsdkInfo.szPfKey, szPayUid, szServiceCode, szServiceName, szProductId, "", 1, false)
  end
end
function Sdk:PayQQVip(szType)
  if not Sdk:CheckPayCondition() then
    return
  end
  if IOS then
    me.CenterMsg("游戏内不支持充值QQ会员")
    return
  end
  if not Sdk:IsLoginByQQ() then
    me.CenterMsg("使用QQ登入方可进行会员充值")
    return
  end
  RemoteServer.SdkRequest("PayReq", "Sdk:RealPayQQVip", szType)
end
function Sdk:RealPayQQVip(szAcc, szPayUid, szType)
  local szServiceName = ""
  local szServiceCode = ""
  local nServiceType = 1
  if szType == "VIP" then
    szServiceName = "QQ会员"
    szServiceCode = "LTMCLUB"
  elseif szType == "SVIP" then
    szServiceName = "QQ超级会员"
    szServiceCode = "CJCLUBT"
    if me.GetQQVipInfo() == Player.QQVIP_VIP then
      nServiceType = 3
    end
  else
    me.CenterMsg("未知会员类型")
    return
  end
  local tbMsdkInfo = Sdk:GetMsdkInfo()
  self.szLastPayType = "QQVip"
  self.bIsPayingQQVip = true
  SdkMgr.MidasPaySubscribe(Sdk.szAndroidOfferId, szAcc, tbMsdkInfo.szPayOpenKey, tbMsdkInfo.szSessionId, tbMsdkInfo.szSessionType, tbMsdkInfo.szPf, tbMsdkInfo.szPfKey, szPayUid, szServiceCode, szServiceName, "", Sdk.szMsdkAid, nServiceType, true)
end
function Sdk:UpdateBalanceInfo()
  RemoteServer.UpdateBalanceInfo()
end
function Sdk:UploadMsdkInfo(bLogin)
  local tbMsdkInfo = Sdk:GetMsdkInfo()
  RemoteServer.UpdateMsdkInfo(tbMsdkInfo, bLogin)
end
function Sdk:ReportGameCenterPlat()
  local nLaunchPlat = Sdk:GetValidLaunchPlatform()
  if nLaunchPlat == Sdk.ePlatform_None or nLaunchPlat == Sdk.ePlatform_Guest then
    return
  end
  RemoteServer.SdkRequest("ReportLaunchPlat", nLaunchPlat)
end
function Sdk:OnPayNotify(szPayRet)
  Log("Sdk:OnPayNotify")
  Log(szPayRet)
  self.nNextPayTime = nil
  local tbPayRet = Lib:DecodeJson(szPayRet) or {}
  local szRetrunType
  if tbPayRet.resultCode == Sdk.eMidas_PAYRESULT_SUCC and tbPayRet.payState == Sdk.eMidas_PAYSTATE_PAYSUCC then
    szRetrunType = "PAYSUCC"
  elseif tbPayRet.resultCode == Sdk.eMidas_PAYRESULT_CANCEL then
    szRetrunType = "CANCEL"
  else
    szRetrunType = "ERROR"
  end
  self:ReportPayData(szRetrunType)
  if tbPayRet.resultCode == Sdk.eMidas_PAYRESULT_SUCC and tbPayRet.payState == Sdk.eMidas_PAYSTATE_PAYSUCC then
    if self.szLastPayType == "Daoju" then
      me.CenterMsg("支付成功，请注意查收")
      return
    end
    if self.bIsPayingQQVip then
      RemoteServer.SdkRequest("MarkPayQQVip")
      self.bIsPayingQQVip = nil
      return
    end
    Recharge.nLastTotalRechare = Recharge:GetTotoalRecharge(me)
    UiNotify.OnNotify(UiNotify.emNOTIFY_RECHARGE_PANEL)
    do
      local nExpireTime = GetTime() + 120
      local function fnUpdateBalance()
        if Recharge.nLastTotalRechare ~= Recharge:GetTotoalRecharge(me) then
          UiNotify.OnNotify(UiNotify.emNOTIFY_RECHARGE_PANEL)
          return false
        end
        if GetTime() >= nExpireTime then
          return false
        end
        Sdk:UpdateBalanceInfo()
        return true
      end
      Sdk:UpdateBalanceInfo()
      Timer:Register(Env.GAME_FPS * 15, fnUpdateBalance)
    end
  else
    me.CenterMsg("支付失败 " .. (tbPayRet.resultMsg or ""))
  end
end
function Sdk:OnPayNeedLogin(szInfo)
  self:ReportPayData("LoginExpiry")
  local fnReturn = function()
    Sdk:Logout()
    Ui:ReturnToLogin()
    CloseServerConnect()
  end
  if IOS then
    local szMsg = "授权过期, 需要重新授权登录"
    Ui:OpenWindow("MessageBox", szMsg, {
      {fnReturn}
    }, {"确定"}, nil, nil, true)
  else
    fnReturn()
  end
end
function Sdk:BindWeixinGroup(nKinId, szChatRoomName)
  if not Sdk:IsMsdk() then
    return
  end
  local szUnionId = string.format("%d_%d", Kin:GetOrgServerId(), nKinId)
  SdkMgr.CreateWeixinGroup(szUnionId, szChatRoomName, me.szName)
end
function Sdk:JoinWeixinGroup(nKinId)
  if not Sdk:IsMsdk() then
    return
  end
  local szUnionId = string.format("%d_%d", Kin:GetOrgServerId(), nKinId)
  SdkMgr.JoinWeixinGroup(szUnionId, me.szName)
end
function Sdk:OnCreateWeixinGroupNotify(szCreateUrl, nErrorCode)
  if Sdk.eWXGroupRet_NotPermit[nErrorCode] then
    me.CenterMsg("游戏没有建群权限")
  elseif Sdk.eWXGroupRet_IDExist[nErrorCode] then
    me.CenterMsg("群ID已存在")
  elseif Sdk.eWXGroupRet_OverCreateNum[nErrorCode] then
    me.CenterMsg("建群数量超过上限")
  elseif Sdk.eWXGroupRet_ParamErr[nErrorCode] then
    me.CenterMsg("参数错误")
  elseif #szCreateUrl > 1 then
    Sdk:OpenUrl(szCreateUrl)
  end
end
function Sdk:OnJoinWeixinGroupNotify(szJoinUrl, nErrorCode)
  if Sdk.eWXGroupRet_NotPermit[nErrorCode] then
    me.CenterMsg("游戏没有建群权限")
  elseif Sdk.eWXGroupRet_IDExist[nErrorCode] then
    me.CenterMsg("群ID已存在")
  elseif Sdk.eWXGroupRet_OverCreateNum[nErrorCode] then
    me.CenterMsg("建群数量超过上限")
  elseif Sdk.eWXGroupRet_ParamErr[nErrorCode] then
    me.CenterMsg("参数错误")
  elseif Sdk.eWXGroupRet_IDNotExist[nErrorCode] then
    me.CenterMsg("群ID不存在")
  elseif #szJoinUrl > 1 then
    Sdk:OpenUrl(szJoinUrl)
  end
end
function Sdk:BindQQGroup(nKinId, szKinName)
  if not Sdk:IsMsdk() then
    return
  end
  if not Sdk:IsPlatformInstalled(Sdk.ePlatform_QQ) then
    me.CenterMsg("您尚未安装QQ, 无法进行Q群的绑定")
    return
  end
  local szZoneId = tostring(Kin:GetOrgServerId())
  local szOpenId = Sdk:GetUid()
  local szAppId = Sdk:GetCurAppId()
  local szAppKey = Sdk:GetCurAppKey()
  local szSign = KLib.GetStringMd5(string.format("%s_%s_%s_%d_%s", szOpenId, szAppId, szAppKey, nKinId, szZoneId))
  Log("Sdk:BindQQGroup", tostring(nKinId), szKinName, szZoneId, szSign)
  SdkMgr.BindQQGroup(nKinId, szKinName, szZoneId, szSign)
end
function Sdk:UnbindQQGroup(szGroupOpenId, nKinId)
  if not Sdk:IsMsdk() then
    return
  end
  Log("Sdk:UnBindQQGroup", szGroupOpenId, nKinId)
  SdkMgr.UnbindQQGroup(szGroupOpenId, tostring(nKinId))
end
function Sdk:JoinQQGroup(szGroupKey)
  if not Sdk:IsMsdk() then
    return
  end
  SdkMgr.JoinQQGroup(szGroupKey)
end
function Sdk:QueryGroupInfo(nKinId)
  if not Sdk:IsMsdk() then
    return
  end
  if Sdk:IsLoginByQQ() then
    SdkMgr.QueryQQGroupInfo(tostring(nKinId), tostring(Kin:GetOrgServerId()))
  elseif Sdk:IsLoginByWeixin() then
    local szUnionId = string.format("%d_%d", Kin:GetOrgServerId(), nKinId)
    SdkMgr.QueryWeixinGroup(szUnionId, Sdk:GetUid())
  end
end
function Sdk:QueryQQGroupKey(szGroupOpenId)
  if not Sdk:IsMsdk() then
    return
  end
  SdkMgr.QueryQQGroupKey(szGroupOpenId)
end
function Sdk:OnBindGroupNotify(groupInfo)
  Log("Sdk:OnBindGroupNotify", groupInfo)
  Kin:UpdateGroupInfo(true)
end
function Sdk:OnUnbindGroupNotify(groupInfo)
  Log("Sdk:OnUnbindGroupNotify", groupInfo)
  Kin:UpdateGroupInfo(true)
end
function Sdk:OnQueryGroupInfoNotify(groupInfo)
  Log("Sdk:OnQueryGroupInfoNotify", groupInfo)
  if Sdk:IsLoginByQQ() then
    local tbGroupInfo = groupInfo.mQQGroupInfo or {}
    local tbBaseInfo = Kin:GetBaseInfo() or {}
    if groupInfo._errorCode == 0 then
      if tbBaseInfo.szGroupName ~= tbGroupInfo._groupName or tbBaseInfo.szGroupOpenId ~= tbGroupInfo._groupOpenid then
        Kin:UpdateGroupInfo(true)
      end
    elseif groupInfo._errorCode == Sdk.eQQGroupRet_NotBind and (tbBaseInfo.szGroupName or tbBaseInfo.szGroupOpenId) then
      Kin:UpdateGroupInfo(true)
    end
    UiNotify.OnNotify(UiNotify.emNOTIFY_GROUP_INFO, groupInfo._errorCode)
  end
  if Sdk:IsLoginByWeixin() then
    local nErrorCode = groupInfo.errorCode
    local tbGroupInfo = groupInfo.mWXGroupInfo
    if nErrorCode == Sdk.eWXGroupRet_Suss then
    end
    UiNotify.OnNotify(UiNotify.emNOTIFY_GROUP_INFO, nErrorCode)
  end
end
function Sdk:OnQueryQQGroupKeyNotify(groupInfo)
  Log("Sdk:OnQueryQQGroupKeyNotify", groupInfo)
end
function Sdk:OnRealNameAuthNotify(ret)
  Log("Sdk:OnRealNameAuthNotify", ret, ret.errorCode)
end
function Sdk:iOSPay(szProductId, nCount, bGold, szAcc, szPayUid)
  if not SdkMgr.IsSupportIapPay() then
    me.CenterMsg("您的设备不支持IAP支付.")
    return
  end
  local tbMsdkInfo = Sdk:GetMsdkInfo()
  SdkMgr.MidasIOSPay(Sdk.sziOSOfferId, szAcc, tbMsdkInfo.szOpenKey, tbMsdkInfo.szSessionId, tbMsdkInfo.szSessionType, tostring(nCount), szProductId, tbMsdkInfo.szPf, tbMsdkInfo.szPfKey, bGold, bGold and 0 or 4, szPayUid, "", "")
end
function Sdk:OnPayNetWorkError(state)
  self.nNextPayTime = nil
  Log("Sdk:OnPayNetWorkError: ", state)
  me.CenterMsg("支付过程中网络错误, 请稍后再试:" .. state)
end
function Sdk:ReportPayData(pay_type_result)
  local tbRepartParam = self.tbRepartParam
  if not tbRepartParam then
    return
  end
  SdkMgr.ReportPayEnterGame(tostring(Ui:GetClass("Login"):GetVersionDesc()), tostring(SERVER_ID), tostring(me.nLevel), tostring(tbRepartParam.buy_dia_channel), tostring(tbRepartParam.buy_dia_id), tostring(pay_type_result), tostring(tbRepartParam.buy_quantity), tostring(IsJailbroken()))
end
function Sdk:OnIOSOrderSuccess(szJsonRet)
  self:ReportPayData("OrderFinish")
  Log("Sdk:OnIOSOrderSuccess: ", szJsonRet)
end
function Sdk:OnIOSOrderFail(szInfo)
  self.nNextPayTime = nil
  self:ReportPayData("OrderFailue")
  Log("Sdk:OnIOSOrderFail: ", szInfo)
  me.CenterMsg("获取支付定单失败:" .. szInfo)
end
function Sdk:OnIOSPaySuccess(szJsonRet)
  self:ReportPayData("IAPPayFinish")
  Log("Sdk:OnIOSPaySuccess: ", szJsonRet)
  me.CenterMsg("付款成功, 请稍后...")
end
function Sdk:OnIOSPayFail(szJsonRet)
  self.nNextPayTime = nil
  self:ReportPayData("IAPPayFailue")
  Log("Sdk:OnIOSPayFail: ", szJsonRet)
  me.CenterMsg("支付失败, 请稍后再试...")
end
function Sdk:OnDistributeGoodsSuccess(szJsonRet)
  self.nNextPayTime = nil
  self:ReportPayData("DistributeGoodsFinish")
  Log("Sdk:OnDistributeGoodsSuccess: ", szJsonRet)
  local nExpireTime = GetTime() + 120
  local nTotalCharge = Recharge:GetTotoalRecharge(me)
  local function fnUpdateBalance()
    if nTotalCharge ~= Recharge:GetTotoalRecharge(me) or GetTime() >= nExpireTime then
      return false
    end
    Sdk:UpdateBalanceInfo()
    return true
  end
  me.CenterMsg("发货成功, 请注意查收")
  if self.szLastPayType == "Daoju" then
    return
  end
  Sdk:UpdateBalanceInfo()
  Timer:Register(Env.GAME_FPS * 15, fnUpdateBalance)
end
function Sdk:OnDistributeGoodsFailure(code)
  self.nNextPayTime = nil
  self:ReportPayData("DistributeGoodsFailue")
  Log("Sdk:OnDistributeGoodsFailure: ", code)
  me.CenterMsg("发货失败, 请稍后:" .. code)
end
function Sdk:OnGetPayProductInfoErr(szInfo)
  self.nNextPayTime = nil
  self:ReportPayData("GetProductInfoFailue")
  Log("Sdk:OnGetPayProductInfoErr: ", szInfo)
  me.CenterMsg("拉取物品信息失败, 请稍后再试:" .. szInfo)
end
function Sdk:CheckOpenId()
  if not Sdk:Available() then
    return true
  end
  if Sdk:GetUid() ~= SdkMgr.GetOpenId() then
    Ui:OpenWindow("MessageBox", "授权异常, 需要重新授权登录", {
      {
        function()
          Sdk:Logout()
          Ui:ReturnToLogin()
          CloseServerConnect()
        end
      }
    }, {"确认"}, nil, nil, true)
    return false
  end
  return true
end
local tbLoginFailTips = {
  [Sdk.eFlag_WX_UserDeny] = "您拒绝微信授权",
  [Sdk.eFlag_WX_NotInstall] = "您的设备未安装微信客户端",
  [Sdk.eFlag_WX_UserCancel] = "您取消了微信登入",
  [Sdk.eFlag_WX_NotSupportApi] = "您的微信客户端不支持此接口逻辑",
  [Sdk.eFlag_QQ_UserCancel] = "您取消了QQ授权",
  [Sdk.eFlag_QQ_NotInstall] = "您的设备未安装QQ客户端",
  [Sdk.eFlag_QQ_NotSupportApi] = "您的QQ客户端不支持此接口逻辑",
  [Sdk.eFlag_QQ_NetworkErr] = "网络出问题啦,请稍后再试",
  [Sdk.eFlag_Error] = "未知系统错误，请稍后再试"
}
local tbLoginNotifyDealer = {
  [Sdk.eFlag_Succ] = function(nFlag, nPlatform, szOpenId, szToken)
    Sdk.nCurPlatform = nPlatform
    local bNeedLogin = not Login.bEnterGame and IsServerConnected() == 0
    if bNeedLogin then
      Ui:CloseWindow("LoadingTips")
      Ui:AddCenterMsg("已授权")
      local fnReturn = function()
        Sdk:Logout()
        Ui:ReturnToLogin()
      end
      local function fnContinue()
        Login:ConnectGateWay(szOpenId, szToken, nPlatform)
      end
      local nWakeupPlat = Sdk:GetWakeupPlatform()
      if nWakeupPlat ~= Sdk.ePlatform_None and nWakeupPlat ~= nPlatform then
        local szTargePlat = nWakeupPlat == Sdk.ePlatform_QQ and "QQ" or "微信"
        local szMsg = string.format("启动平台与已登入平台不一致,\n 是否切换为%s账号登入?", szTargePlat)
        Ui:OpenWindow("MessageBox", szMsg, {
          {fnReturn},
          {fnContinue}
        }, {"切换", "取消"}, nil, nil, true)
        return
      end
      local szLaunchOpenId = SdkMgr.GetCurLaunchOpenId() or ""
      if string.len(szLaunchOpenId) > 10 and szLaunchOpenId ~= szOpenId then
        Ui:OpenWindow("MessageBox", "启动账号与当前登入的账号不一致,\n 是否切换账号?", {
          {fnReturn},
          {fnContinue}
        }, {"切换", "取消"}, nil, nil, true)
        return
      end
      fnContinue()
    elseif Sdk:CheckOpenId() then
      Sdk:MidasInit()
      Sdk:UploadMsdkInfo()
    end
  end,
  [Sdk.eFlag_Error] = function(nFlag, nPlatform, ...)
    if tbLoginFailTips[nFlag] then
      Ui:OpenWindow("MessageBox", "登入失败:\n" .. tbLoginFailTips[nFlag], {})
    else
      Ui:OpenWindow("MessageBox", string.format("登入失败(错误码%d)\n如尝试多次仍无法登陆，请将此错误代码上报客服。对此带来的不便，敬请见谅！", nFlag), {})
    end
    Sdk:Logout()
  end,
  [Sdk.eFlag_Local_Invalid] = function()
    Ui:CloseWindow("LoadingTips")
    if not Ui:WindowVisible("Login") then
      Ui:OpenWindow("MessageBox", "登入凭证失效, 请返回重新登入", {
        {
          function()
            Ui:ReturnToLogin()
            CloseServerConnect()
          end
        }
      }, {"确认"}, nil, nil, true)
    else
      local nWakeupPlat = Sdk:GetWakeupPlatform()
      if nWakeupPlat == Sdk.ePlatform_Weixin or nWakeupPlat == Sdk.ePlatform_QQ then
        Sdk:Login(nWakeupPlat)
      end
    end
  end
}
local tbLoginFlagEqual = {
  [Sdk.eFlag_WX_RefreshTokenSucc] = Sdk.eFlag_Succ,
  [Sdk.eFlag_QQ_AccessTokenExpired] = Sdk.eFlag_Local_Invalid,
  [Sdk.eFlag_QQ_PayTokenExpired] = Sdk.eFlag_Local_Invalid,
  [Sdk.eFlag_WX_RefreshTokenFail] = Sdk.eFlag_Local_Invalid,
  [Sdk.eFlag_WX_RefreshTokenExpired] = Sdk.eFlag_Local_Invalid,
  [Sdk.eFlag_WX_AccessTokenExpired] = Sdk.eFlag_Local_Invalid
}
function Sdk:OnLoginResult(nFlag, nPlatform, ...)
  self.nNextLoginTime = nil
  Login:SetAutoLogin(true)
  Log("Sdk:OnLoginResult:", nFlag, nPlatform, ...)
  self.nCurPlatform = nil
  self.bForIOSServer = Client:GetFlag("ForIOSServer", -1)
  nFlag = tbLoginFlagEqual[nFlag] or nFlag
  local fnDeal = tbLoginNotifyDealer[nFlag] or tbLoginNotifyDealer[Sdk.eFlag_Error]
  fnDeal(nFlag, nPlatform, ...)
  SdkMgr.ReportDataMSDKLogin(tostring(nFlag), self:GetCurAppId(), tostring(SERVER_ID))
end
function Sdk:OnRelationNotify(nFlag, nPlatform, personsObj)
  Log("Sdk:OnRelationNotify", nFlag, nPlatform, personsObj.Count)
  if nFlag ~= Sdk.eFlag_Succ then
    return
  end
  local tbPlatFriendsInfo = FriendShip:GetPlatFriendsInfo() or {}
  local nFriendCount = personsObj.Count or 0
  for i = 0, nFriendCount - 1 do
    local personData = personsObj[i]
    if personData then
      local tbInfo = {
        szNickName = personData.nickName,
        szOpenId = personData.openId,
        szHeadSmall = personData.pictureSmall,
        szGender = personData.gender
      }
      if tbInfo.szOpenId == "" and nFriendCount == 1 then
        tbInfo.szOpenId = Sdk:GetUid()
      end
      table.insert(tbPlatFriendsInfo, tbInfo)
    end
  end
  FriendShip:SetPlatFriendsInfo(tbPlatFriendsInfo)
  local tbPlatFriendData = Client:GetDirFileData("PlatFriend" .. Sdk:GetUid())
  tbPlatFriendData.tbFriendsInfo = tbPlatFriendsInfo
  Client:SaveDirFileData("PlatFriend" .. Sdk:GetUid())
end
function Sdk:OnRankInfoRsp(szType, szRetInfo)
  Log("Sdk:OnRankInfoRsp", szType, szRetInfo)
  local tbRetInfo = Lib:DecodeJson(szRetInfo)
  local szMyOpenId = Sdk:GetUid()
  local tbPlatFriendData = Client:GetDirFileData("PlatFriend" .. szMyOpenId)
  if szType == "rank" then
    local tbFriendsInfo = FriendShip:GetPlatFriendsInfo()
    for _, tbFriendInfo in ipairs(tbFriendsInfo) do
      local tbInfo = tbRetInfo[tbFriendInfo.szOpenId] or {}
      if tbFriendInfo.szOpenId == szMyOpenId then
        tbInfo = {
          Power = me.GetNpc().GetFightPower(),
          PlayerId = me.dwID,
          Name = me.szName,
          LaunchPlat = Sdk:GetValidLaunchPlatform(),
          ServerId = SERVER_ID,
          VipType = me.GetQQVipInfo(),
          Level = me.nLevel
        }
      end
      tbFriendInfo.nPower = tbInfo.Power
      tbFriendInfo.nPlayerId = tbInfo.PlayerId
      tbFriendInfo.szName = tbInfo.Name
      tbFriendInfo.nLaunchPlat = tbInfo.LaunchPlat
      tbFriendInfo.nServerId = tbInfo.ServerId
      tbFriendInfo.nQQVipType = tbInfo.VipType
      tbFriendInfo.nLevel = tbInfo.Level
    end
    for i = #tbFriendsInfo, 1, -1 do
      local tbInfo = tbFriendsInfo[i]
      if not tbInfo.nPlayerId then
        table.remove(tbFriendsInfo, i)
      end
    end
    table.sort(tbFriendsInfo, function(a, b)
      if a.nLevel == b.nLevel then
        if a.nPower == b.nPower then
          return a.szNickName < b.szNickName
        end
        return a.nPower > b.nPower
      end
      return a.nLevel > b.nLevel
    end)
    tbPlatFriendData.tbFriendsInfo = tbFriendsInfo
    Client:SaveDirFileData("PlatFriend" .. szMyOpenId)
  end
  if szType == "gift" then
    local tbGiftInfo = {}
    for _, szOpenId in pairs(tbRetInfo) do
      tbGiftInfo[szOpenId] = true
    end
    tbPlatFriendData.nGiftInfoDay = Lib:GetLocalDay()
    tbPlatFriendData.tbGiftInfo = tbGiftInfo
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_PLAT_FRIEND_INFO)
end
function Sdk:QueryRankSendInfo()
  local nNow = GetTime()
  if self.nNextUpdateRankSendTime and nNow < self.nNextUpdateRankSendTime then
    return false
  end
  self.nNextUpdateRankSendTime = nNow + 10
  RemoteServer.SdkRequest("QueryRankSendInfo")
end
function Sdk:SendFriendRankGift(szOpenId, nServerId, nPlayerId, szFriendName)
  if szOpenId == Sdk:GetUid() then
    me.CenterMsg("不可对自己进行赠送")
    return
  end
  if not nPlayerId or nPlayerId == 0 then
    me.CenterMsg("无法对其它大区进行赠送")
    return
  end
  RemoteServer.SdkRequest("SendFriendRankGift", szOpenId, nServerId, nPlayerId, szFriendName)
end
function Sdk:QueryRankServerInfo()
  local nNow = GetTime()
  if self.nNextUpdateFriendRankTime and nNow < self.nNextUpdateFriendRankTime then
    return false
  end
  self.nNextUpdateFriendRankTime = nNow + 10
  local tbFriendsInfo = FriendShip:GetPlatFriendsInfo() or {}
  local tbOpenIds = {}
  for i, tbInfo in ipairs(tbFriendsInfo) do
    if i > 100 then
      break
    end
    table.insert(tbOpenIds, tbInfo.szOpenId)
  end
  if not next(tbOpenIds) then
    return false
  end
  local szOpenIds = table.concat(tbOpenIds, ",")
  RemoteServer.SdkRequest("QueryRankInfo", szOpenIds)
  return true
end
function Sdk:GetWakeupPlatform()
  return SdkMgr.GetWakeupPlatform()
end
function Sdk:OnWakeupNotify(nFlag, szOpenId)
  Log("Sdk:OnWakeupNotify", nFlag, szOpenId, Sdk:GetUid(), SdkMgr.GetOpenId(), Sdk:GetWakeupPlatform())
  if not Sdk:Available() then
    return
  end
  local fnSwitch = function()
    Sdk:Logout()
    Ui:ReturnToLogin()
    CloseServerConnect()
  end
  local nWakeupPlat = Sdk:GetWakeupPlatform()
  if Sdk.nCurPlatform and nWakeupPlat ~= Sdk.ePlatform_None and nWakeupPlat ~= Sdk.nCurPlatform then
    local szTargePlat = nWakeupPlat == Sdk.ePlatform_QQ and "QQ" or "微信"
    local szMsg = string.format("唤醒平台与已登入平台不一致,\n 是否切换为%s账号登入?", szTargePlat)
    Ui:OpenWindow("MessageBox", szMsg, {
      {fnSwitch},
      {}
    }, {"切换", "取消"}, nil, nil, true)
    return
  end
  local szSdkOpenId = szOpenId and szOpenId ~= "" and szOpenId or SdkMgr.GetOpenId()
  if Sdk.nCurPlatform and szSdkOpenId ~= Sdk:GetUid() and string.len(szSdkOpenId) > 10 or nFlag == Sdk.eFlag_NeedSelectAccount then
    Ui:OpenWindow("MessageBox", "唤醒账号与当前游戏中的账号不一致,\n 是否切换账号?", {
      {fnSwitch},
      {}
    }, {"切换", "取消"}, nil, nil, true)
    return
  end
  if not Login.bEnterGame then
    Sdk:LoginWithLocalInfo()
  end
  Sdk:ReportGameCenterPlat()
end
function Sdk:GetLaunchPlatform()
  if not Sdk:IsMsdk() then
    return Sdk.ePlatform_None
  end
  if Sdk:IsOuterChannel() then
    return Sdk.ePlatform_None
  end
  if Sdk:IsLoginByGuest() then
    return Sdk.ePlatform_Guest
  end
  local nCurLaunchPlat = SdkMgr.GetCurLaunchPlatform()
  if nCurLaunchPlat ~= Sdk.ePlatform_None then
    return nCurLaunchPlat
  end
  return me.GetLaunchedPlatform()
end
function Sdk:GetValidLaunchPlatform()
  if Client:IsCloseIOSEntry() then
    return Sdk.ePlatform_None
  end
  local nCurLaunchPlat = Sdk:GetLaunchPlatform()
  if nCurLaunchPlat == Sdk:GetCurPlatform() then
    return nCurLaunchPlat
  end
  return Sdk.ePlatform_None
end
function Sdk:OnNoChannelExit()
  Sdk:OnReturnPressed()
end
function Sdk:OnReturnPressed()
  Ui:OnReturnPressed()
end
function Sdk:DirectExit()
  SdkMgr.QuitApplication()
end
function Sdk:GetCurPlatform()
  return self.nCurPlatform or Sdk.ePlatform_None
end
function Sdk:IsLoginByQQ()
  return self.nCurPlatform == Sdk.ePlatform_QQ or self.nCurPlatform == Sdk.ePlatform_QQHall
end
function Sdk:ShowQQVipPrivilege()
  return self:IsLoginByQQ() and ANDROID and not Sdk:IsLoginForIOS() and not Sdk:IsOuterChannel()
end
function Sdk:IsLoginByWeixin()
  return self.nCurPlatform == Sdk.ePlatform_Weixin
end
function Sdk:IsLoginByGuest()
  return self.nCurPlatform == Sdk.ePlatform_Guest
end
function Sdk:GetTssPlatformId()
  if self.nCurPlatform == Sdk.ePlatform_QQ or self.nCurPlatform == Sdk.ePlatform_QQHall then
    return TssSdkEntryId.ENTRY_ID_QZONE
  elseif self.nCurPlatform == Sdk.ePlatform_Weixin then
    return TssSdkEntryId.ENTRY_ID_MM
  else
    return TssSdkEntryId.ENTRY_ID_OTHERS
  end
end
function Sdk:GetCurAppKey()
  if Sdk:IsLoginByQQ() then
    return Sdk.szQQAppKey
  elseif Sdk:IsLoginByWeixin() then
    return Sdk.szWXAppKey
  else
    return ""
  end
end
function Sdk:GetCurAppId()
  if self.nCurPlatform == Sdk.ePlatform_QQ or self.nCurPlatform == Sdk.ePlatform_QQHall then
    return Sdk.szQQAppId
  elseif self.nCurPlatform == Sdk.ePlatform_Weixin then
    return Sdk.szWxAppId
  else
    return ""
  end
end
function Sdk:UpdateBuluoUrl()
  RemoteServer.SdkRequest("AskBuluoUrl", Sdk:GetOsType())
end
function Sdk:Ask4QQVipAward(nVipType, szAwardType)
  RemoteServer.SdkRequest("Ask4QQVipAward", nVipType, szAwardType)
end
function Sdk:OnSyncBuluoUrl(szUrl)
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_QQ_BULUO_URL, szUrl)
end
function Sdk:XinyueOpen()
  if Sdk:IsLoginByGuest() then
    return false
  end
  return not self.bCloseXinyue
end
function Sdk:SetXinyueState(bClose)
  self.bCloseXinyue = bClose
end
function Sdk:OpenXinyueUrl()
  local szUrl = Sdk.szXinyueUrl
  local szAppId = Sdk:GetCurAppId()
  local szOpenId = Sdk:GetUid()
  local szAccesskey = SdkMgr.GetAccessOpenKey()
  local szLoginType = Sdk:IsLoginByQQ() and "1" or "2"
  local nPartitionId = Sdk:GetServerId()
  local nLoginPlatId = Sdk:GetLoginPlatId()
  local szOpenCode = table.concat({
    szOpenId,
    szAccesskey,
    szAppId,
    szLoginType
  }, ",")
  szOpenCode = Lib:Base64Encode(szOpenCode)
  local szUrlTail = string.format("?game_id=%s&opencode=%s&partition_id=%d&role_id=%d&loginplatid=%d", Sdk.szXinyueGameId, szOpenCode, nPartitionId, me.dwID, nLoginPlatId)
  Sdk:OpenUrl(szUrl .. szUrlTail)
end
function Sdk:SharePhoto(szType, szTagName, szMsgExt, szMediaAction)
  Log("Sdk:SharePhoto", szType, szTagName, szMsgExt, szMediaAction)
  if not Sdk:CheckShareType(szType) then
    return
  end
  self.szLastSharPhotoType = szType
  SdkMgr.SharePhoto(szType, szTagName or "MSG_INVITE", szMsgExt or "", szMediaAction or "WECHAT_SNS_JUMP_APP")
end
function Sdk:ShareUrl(szType, szTitle, szDesc, szTagName, szUrl, szImgUrl)
  Log("Sdk:ShareUrl", szType, szTitle, szDesc, szTagName, szUrl, szImgUrl)
  if not Sdk:CheckShareType(szType) then
    return
  end
  if not szUrl then
    local szUrlFormat = "http://gamecenter.qq.com/gcjump?appid=%s&pf=invite&from=%s&plat=qq&originuin=%s&ADTAG=%s"
    local szAppId = Sdk:GetCurAppId()
    local szOpenId = Sdk:GetUid()
    local szFrom = IOS and "iphoneqq" or "androidqq"
    local szAddTag = "gameobj.msg_invite"
    szUrl = string.format(szUrlFormat, szAppId, szFrom, szOpenId, szAddTag)
  end
  SdkMgr.ShareUrl(szType, szTitle or "快来玩剑侠情缘", szDesc or "二十年原班人马打造，多门派会战江湖，你不来试试？", szTagName or "MSG_INVITE", szUrl or "", szImgUrl or "http://download.wegame.qq.com/gc/formal/common/1105054046/thumImg.png")
end
function Sdk:TlogShare(szType, ...)
  RemoteServer.SdkRequest("TlogShare", szType, ...)
end
function Sdk:OpenWeixinDeepLink(szUrl)
  Log("Sdk:OpenWeixinDeepLink", szUrl)
  if not Sdk:IsPlatformInstalled(Sdk.ePlatform_Weixin) then
    me.CenterMsg("未安装微信")
    return
  end
  SdkMgr.OpenWeixinDeeplink(szUrl)
end
function Sdk:ShareMusic(szType, szTitle, szDesc, szMusicUrl, szMusicDataUrl, szMusicImgUrl)
  if not Sdk:CheckShareType(szType) then
    return
  end
  SdkMgr.ShareMusic(szType, szTitle or "剑侠情缘", szDesc or "剑侠情缘手游", szMusicUrl or "http://y.qq.com/#type=song&mid=0009EZvy0EgwRG", szMusicDataUrl or "http://wekf.qq.com/cry.mp3", szMusicImgUrl or "http://sqimg.qq.com/qq_product_operations/im/qqlogo/imlogo.png")
end
function Sdk:CheckShareType(szType)
  if not szType then
    return false
  end
  if (szType == "QQ" or szType == "QZone") and not Sdk:IsPlatformInstalled(Sdk.ePlatform_QQ) then
    if not Client:IsCloseIOSEntry() then
      me.CenterMsg("未安装手Q")
    else
      me.CenterMsg("暂时无法分享")
    end
    return false
  elseif (szType == "WX" or szType == "WXMo" or szType == "WXSe") and not Sdk:IsPlatformInstalled(Sdk.ePlatform_Weixin) then
    if not Client:IsCloseIOSEntry() then
      me.CenterMsg("未安装微信")
    else
      me.CenterMsg("暂时无法分享")
    end
    return false
  end
  return true
end
function Sdk:OnShareNotify(nFlag, szExtInfo)
  if nFlag == Sdk.eFlag_Succ then
    me.CenterMsg("操作成功")
  else
    me.CenterMsg("操作失败")
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_PLAT_SHARE_RESULT, nFlag == Sdk.eFlag_Succ, self.szLastSharPhotoType)
end
function Sdk:OnQQVipChanged()
  UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_QQ_VIP_INFO)
end
function Sdk:GetAreaId()
  return Sdk:GetAreaIdByPlatform(self.nCurPlatform)
end
function Sdk:GetPlatId()
  if IOS then
    return 0
  else
    return 1
  end
end
function Sdk:GetLoginPlatId()
  if IOS or Sdk:IsLoginForIOS() then
    return 0
  else
    return 1
  end
end
function Sdk:OnSyncCommunityRedPointInfo(tbRedPointData)
  self.tbCommunityRedPointData = tbRedPointData
end
function Sdk:ClearCommunityRedPoint(szRedPoint)
  if self.tbCommunityRedPointData then
    local nVersion = self.tbCommunityRedPointData[szRedPoint]
    if nVersion and Client:GetFlag("RedPoint_" .. szRedPoint) ~= nVersion then
      Client:SetFlag("RedPoint_" .. szRedPoint, nVersion)
    end
  end
end
function Sdk:CheckRedPoint()
  if version_tx then
    local bSeenAuth = Client:GetFlag("SeenRealNameAuth")
    if not bSeenAuth and Sdk:ShowHomeScreenRealAuth() then
      Ui:SetRedPointNotify("RealNameAuth")
    end
  end
  if version_xm and not Sdk:XMIsFacebookClickAwardSend(me) and me.nLevel >= 15 then
    Ui:SetRedPointNotify("XMFacebook")
  end
  local nNow = GetTime()
  for szRedPoint, nTimeOut in pairs(self.tbCommunityRedPointData or {}) do
    if nTimeOut and nTimeOut > nNow and Client:GetFlag("RedPoint_" .. szRedPoint) ~= nTimeOut then
      Ui:SetRedPointNotify(szRedPoint)
    end
  end
end
function Sdk:IsOuterChannel()
  if IOS then
    return false
  end
  if self.bCacheIsOuterChannel ~= nil then
    return self.bCacheIsOuterChannel
  end
  local function fnIsOuter()
    return SdkMgr.IsOuterChannel()
  end
  local bOK, bRet = Lib:CallBack({fnIsOuter})
  self.bCacheIsOuterChannel = bOK and bRet and true or false
  return self.bCacheIsOuterChannel
end
local nHideRealAuthTime = Lib:ParseDateTime("2016/10/22")
function Sdk:ShowHomeScreenRealAuth()
  local nNow = GetTime()
  if nNow >= nHideRealAuthTime then
    return false
  end
  return self.bShowHomeScreenRealAuth or false
end
local tbTXLiveTimeInfo = {
  {
    "2017-01-05 00:00:00",
    "day",
    nil,
    "http://jxqy.qq.com/act/a20161223fbhm/index.shtml"
  },
  {
    "2017-01-05 18:59:59",
    "距开始",
    true
  },
  {
    "2017-01-05 21:00:00",
    "直播中"
  },
  {
    "2017-01-05 23:59:59",
    "已结束"
  }
}
for _, tbInfo in ipairs(tbTXLiveTimeInfo) do
  tbInfo[1] = Lib:ParseDateTime(tbInfo[1])
end
function Sdk:GetTXLiveInfo()
  local nNow = GetTime()
  for i, tbInfo in ipairs(tbTXLiveTimeInfo) do
    if nNow < tbInfo[1] then
      local nLeftTime = tbInfo[1] - nNow
      if tbInfo[2] == "day" then
        return string.format("%d天后开始", math.ceil(nLeftTime / 86400)), nil, nil, tbInfo[4]
      else
        return tbInfo[2], tbInfo[3], nLeftTime
      end
    end
  end
end
local nTXInvitationValidBegin = Lib:ParseDateTime("2017-04-28 00:00:00")
local nTXInvitationValidEnd = Lib:ParseDateTime("2017-05-10 23:59:59")
function Sdk:IsHideTXInvitation()
  local nNow = GetTime()
  if version_tx and nNow > nTXInvitationValidBegin and nNow < nTXInvitationValidEnd then
    return false
  end
  return not self.nShowTXInvitationValidTime or nNow > self.nShowTXInvitationValidTime
end
function Sdk:SetShowTXInvitaionValidTime(nValidTime)
  self.nShowTXInvitationValidTime = nValidTime
end
function Sdk:OpenFreeFlowUrl()
  if Sdk:IsLoginByGuest() then
    me.CenterMsg("游客服无法开通该服务")
    return
  end
  local szOutUid = Sdk:GetUid()
  local szOutUidType = Sdk:IsLoginByQQ() and "2" or "1"
  local nNow = GetTime()
  local szAccesskey = SdkMgr.GetAccessOpenKey()
  local szChannel = "1121_JianXiaApp"
  local szKey = "gn9ndogndhgDngHkLdQdjfd6udn7utgbdofb"
  local szToken = KLib.GetStringMd5(string.format("%s%s%d%s%s", szOutUid, szOutUidType, nNow, szChannel, szKey))
  szToken = string.lower(szToken)
  local szUrl = "http://chong.qq.com/mobile/special_traffic_jianxia.shtml?OutUid=%s&OutUidType=%s&Token=%s&Timestamp=%d&AccessToken=%s&Channel=%s"
  szUrl = string.format(szUrl, szOutUid, szOutUidType, szToken, nNow, szAccesskey, szChannel)
  Sdk:OpenUrl(szUrl)
end
function Sdk:IsFreeFlowShow()
  return true
end
function Sdk:GsdkInit()
  if Sdk.OPEN_GSKD then
    Ui.ToolFunction.GSDKInit(Sdk:GetCurAppId(), false, 1)
    Ui.ToolFunction.GSDKOnLogin()
  end
end
function Sdk:GsdkStart()
  if Sdk.OPEN_GSKD then
    local szIp, nPort = GetServerIpInfo()
    Ui.ToolFunction.GSDKStart(szIp, nPort, SERVER_ID, tostring(me.nMapTemplateId))
  end
end
function Sdk:GsdkEnd()
  if Sdk.OPEN_GSKD then
    Ui.ToolFunction.GSDKEnd(false)
  end
end
function Sdk:OnLevelUp()
  if Sdk:IsXgSdk() then
    Sdk:XGOnRoleLevelUp()
  end
  if version_hk or version_tw or version_xm then
    local nShowLevel = version_xm and 15 or 24
    local tbEnvaluate = Client:GetUserInfo("Evaluate")
    print(tbEnvaluate.bIgnore, me.nLevel)
    if not tbEnvaluate.bIgnore and nShowLevel <= me.nLevel then
      Ui:OpenWindow("EvaluatePanel")
    end
  end
  if version_xm then
    local nLevel = me.nLevel
    if nLevel == 2 then
      Sdk:XGXMTrackEvent("EVENT_FINISH_GUIDE")
    elseif nLevel == 5 then
      Sdk:XGXMTrackEvent("EVENT_ROLELV_5")
    elseif nLevel == 10 then
      Sdk:XGXMTrackEvent("EVENT_ROLELV_10")
    elseif nLevel == 12 then
      Sdk:XGXMTrackEvent("EVENT_ROLELV_12")
    end
  elseif version_th then
    local tbEventName = {
      [3] = "levelup1",
      [7] = "levelup2",
      [13] = "levelup3"
    }
    local szEventName = tbEventName[me.nLevel]
    if szEventName then
      Sdk:AppsFlyerTrackEvent(szEventName, {})
    end
    local tbReportLevel = {
      [7] = true,
      [13] = true,
      [21] = true
    }
    if tbReportLevel[me.nLevel] then
      Sdk:TuneSdkTrackEvent("level_achieved", {
        level = me.nLevel
      })
    end
  end
end
function Sdk:OnVipLevelChanged()
  if version_xm then
    local nVipLevel = me.GetVipLevel()
    if nVipLevel == 1 then
      Sdk:XGXMTrackEvent("EVENT_VIPLV_1")
    elseif nVipLevel == 5 then
      Sdk:XGXMTrackEvent("EVENT_VIPLV_5")
    end
  end
end
function Sdk:ClearFriendRankCache()
  local tbPlatFriendData = Client:GetDirFileData("PlatFriend" .. Sdk:GetUid())
  tbPlatFriendData.nExpireTime = nil
end
function Sdk:DoHttpRequest(szUrl, szPostData, fnCallback)
  Log("Sdk:DoHttpRequest Url:", szUrl)
  Ui.ToolFunction.DoHttpRequest(szUrl, szPostData or "", fnCallback or function(szResult)
    Log("Sdk:DoHttpRequest Info:", szUrl, szPostData)
    Log("Sdk:DoHttpRequest Result:", szResult)
  end)
end
function Sdk:SetQQAddFriendAvailable(bAvailable)
  RemoteServer.SdkRequest("SetQQAddFriendAvailable", bAvailable)
end
function Sdk:RequestAddQQFriend(dwFriendId)
  RemoteServer.SdkRequest("RequestAddQQFriend", dwFriendId)
end
function Sdk:AddQQFriend(szFriendOpenId, szDesc)
  local szMsg = string.format("《剑侠情缘手游》的%s，向您发送了好友申请", me.szName)
  Log("AddQQFriend", szFriendOpenId, szDesc, szMsg)
  SdkMgr.AddGameFriendToQQ(szFriendOpenId, szDesc, szMsg)
end
function Sdk:OpenTXLiveUrl()
  local _, _, _, szUrl = Sdk:GetTXLiveInfo()
  if szUrl then
    Sdk:OpenUrl(szUrl)
    return
  end
  RemoteServer.SdkRequest("RequestOpenTXLiveUrl")
end
function Sdk:OnDaojuChargeRsp(szRetData, szProductId, nServerId)
  Log("Sdk:OnDaojuChargeRsp", szRetData, szProductId)
  if Sdk:IsPCVersion() then
    me.CenterMsg("请使用游戏手机客户端进行购买支付操作")
    return
  end
  local tbRsp = Lib:DecodeJson(szRetData)
  if tbRsp.ret ~= "0" then
    me.MsgBox("购买道具异常，请稍后再试.\n错误码：" .. (tbRsp.ret or ""))
    return
  end
  local tbMsdkInfo = Sdk:GetMsdkInfo()
  if IOS then
    local szPayItem = string.format("%s*%d*1", tbRsp.serial, tonumber(tbRsp.act_amount) / 10)
    local szPf = ""
    if Sdk:IsLoginByQQ() then
      szPf = string.format("qq_m-2001-iap-2011-%s#2005#jxqy#0#%s#%s#iap#7200", tbRsp.serial, tbMsdkInfo.szOpenId, tbRsp.act_amount)
    elseif Sdk:IsLoginByWeixin() then
      szPf = string.format("wechat_wx-2001-iap-2011-%s#2005#jxqy#0#%s#%s#iap#7200", tbRsp.serial, tbMsdkInfo.szOpenId, tbRsp.act_amount)
    end
    szProductId = tbRsp.product_id or szProductId
    SdkMgr.MidasIOSPay(Sdk.szDaojuiOSOfferId, tbMsdkInfo.szOpenId, tbMsdkInfo.szOpenKey, tbMsdkInfo.szSessionId, tbMsdkInfo.szSessionType, szPayItem, szProductId, szPf, "pfKey", false, 0, "1", "20", "")
  elseif ANDROID then
    SdkMgr.MidasPayGoods(tbRsp.offerId, tbMsdkInfo.szOpenId, tbMsdkInfo.szOpenKey, tbMsdkInfo.szSessionId, tbMsdkInfo.szSessionType, tostring(nServerId), tbRsp.pf, "pfKey", tbRsp.urlParams)
  end
  self.szLastPayType = "Daoju"
end
Sdk.tbXGPayInfoList = Sdk.tbXGPayInfoList or {}
function Sdk:XGLogin(szParam)
  self.szXGEfunFacebookId = nil
  SdkMgr.XgLogin(tostring(szParam) or "")
end
function Sdk:XGLogout(szParam)
  SdkMgr.XgLogout(tostring(szParam) or "")
end
function Sdk:XGSwitchAccount(szParam)
  SdkMgr.XgSwitchAccount(tostring(szParam) or "")
end
function Sdk:XGExit(szParam)
  SdkMgr.XgExit(tostring(szParam) or "")
end
function Sdk:XGGetRoleInfo()
  local _, szServerName = Client:GetCurServerInfo()
  local nServerId = Sdk:GetServerId()
  local tbRoleInfo = {
    tostring(GetTime()),
    Sdk:GetUid(),
    tostring(me.dwID),
    me.szName,
    tostring(me.nLevel),
    Faction:GetName(me.nFaction),
    tostring(me.GetVipLevel()),
    tostring(nServerId),
    szServerName,
    me.GetMoney("Gold"),
    tostring(me.dwKinId),
    "m"
  }
  return tbRoleInfo
end
function Sdk:XGOnEnterGame()
  local tbRoleInfo = Sdk:XGGetRoleInfo()
  SdkMgr.XgOnEnterGame(unpack(tbRoleInfo))
end
function Sdk:XGOnRoleLevelUp()
  local tbRoleInfo = Sdk:XGGetRoleInfo()
  SdkMgr.XgOnRoleLevelup(unpack(tbRoleInfo))
end
function Sdk:XGOnRoleCreate()
  local tbRoleInfo = Sdk:XGGetRoleInfo()
  SdkMgr.XgOnCreateRole(unpack(tbRoleInfo))
end
function Sdk:GetXGPayInfo(nServerId, szProductId, szProductName, nPayAmount, szCurrencyName, szTradeNo, szCustomInfo)
  if nServerId ~= Sdk:GetServerId() then
    return
  end
  local szServerId = tostring(nServerId)
  local tbPayInfo = {}
  tbPayInfo.uid = Sdk:GetUid()
  tbPayInfo.productId = szProductId
  tbPayInfo.productName = szProductName
  tbPayInfo.productDesc = szProductName
  tbPayInfo.productUnit = szProductName
  tbPayInfo.productUnitPrice = nPayAmount
  tbPayInfo.productQuantity = 1
  tbPayInfo.totalAmount = nPayAmount
  tbPayInfo.payAmount = nPayAmount
  tbPayInfo.currencyName = szCurrencyName
  tbPayInfo.roleId = tostring(me.dwID)
  tbPayInfo.roleName = me.szName
  tbPayInfo.roleLevel = tostring(me.nLevel)
  tbPayInfo.roleVipLevel = tostring(me.GetVipLevel())
  tbPayInfo.serverId = szServerId
  tbPayInfo.zoneId = "1"
  tbPayInfo.partyName = tostring(me.dwKinId)
  tbPayInfo.virtualCurrencyBalance = tostring(me.GetMoney("Gold"))
  tbPayInfo.customInfo = tostring(szCustomInfo or "customInfo")
  tbPayInfo.gameTradeNo = szTradeNo
  tbPayInfo.gameCallBackURL = ""
  tbPayInfo.additionalParams = ""
  return tbPayInfo
end
function Sdk:XGPay(nServerId, szProductId, szProductName, nPayAmount, szCurrencyName, szTradeNo, szCustomInfo)
  if version_th and Sdk:XGIsWinnerThirdPay() then
    me.CenterMsg("这个礼包只能通过Store充值才获得")
    return
  end
  local tbPayInfo = Sdk:GetXGPayInfo(nServerId, szProductId, szProductName, nPayAmount, szCurrencyName, szTradeNo, szCustomInfo)
  if not tbPayInfo then
    me.CenterMsg("系统异常, 请重新登入后再尝试进行支付")
    return
  end
  Sdk.tbXGPayInfoList[szTradeNo] = tbPayInfo
  SdkMgr.XgPay(tbPayInfo.uid, tbPayInfo.productId, tbPayInfo.productName, tbPayInfo.productDesc, tbPayInfo.productUnit, tbPayInfo.productUnitPrice, tbPayInfo.productQuantity, tbPayInfo.totalAmount, tbPayInfo.payAmount, tbPayInfo.currencyName, tbPayInfo.roleId, tbPayInfo.roleName, tbPayInfo.roleLevel, tbPayInfo.roleVipLevel, tbPayInfo.serverId, tbPayInfo.zoneId, tbPayInfo.partyName, tbPayInfo.virtualCurrencyBalance, tbPayInfo.customInfo, tbPayInfo.gameTradeNo, tbPayInfo.gameCallBackURL, tbPayInfo.additionalParams)
  Log("XGPay", nServerId, szProductId, szProductName, nPayAmount, szCurrencyName, szTradeNo, szCustomInfo)
  if USE_TUNE_SDK then
    self.tbLastPayInfo = {
      revenue = nPayAmount / 100,
      productId = szProductId,
      tradeId = szTradeNo,
      currency = szCurrencyName
    }
  else
    self.tbLastPayInfo = {
      af_revenue = tostring(nPayAmount / 100),
      af_content_type = szProductId,
      af_content_id = tostring(me.dwID),
      af_currency = szCurrencyName
    }
  end
end
function Sdk:XGSurportThridPay()
  return Sdk:GetChannelId() == "efun_third"
end
function Sdk:XGIsWinnerThirdPay()
  return ANDROID and Sdk:GetChannelId() == "winner"
end
function Sdk:XGThirdPay(szAddtionParam)
  local tbPayInfo = Sdk:GetXGPayInfo(Sdk:GetServerId(), "", "", 1, "", "", "")
  SdkMgr.XgPay(tbPayInfo.uid, tbPayInfo.productId, tbPayInfo.productName, tbPayInfo.productDesc, tbPayInfo.productUnit, tbPayInfo.productUnitPrice, tbPayInfo.productQuantity, tbPayInfo.totalAmount, tbPayInfo.payAmount, tbPayInfo.currencyName, tbPayInfo.roleId, tbPayInfo.roleName, tbPayInfo.roleLevel, tbPayInfo.roleVipLevel, tbPayInfo.serverId, tbPayInfo.zoneId, tbPayInfo.partyName, tbPayInfo.virtualCurrencyBalance, tbPayInfo.customInfo, tbPayInfo.gameTradeNo, tbPayInfo.gameCallBackURL, szAddtionParam or "isThirdPartyPaymentSupport")
  Log("XGThirdPay", szAddtionParam)
  self.tbLastPayInfo = nil
end
function Sdk:XGExchangeGiftCode(szGiftCode)
  SdkMgr.XgExchangeGiftCode(Sdk:GetUid(), tostring(me.dwID), "1", tostring(Sdk:GetServerId()), szGiftCode)
end
function Sdk:XGSetEfunFacebookId(szExt)
  local tbExt = Lib:DecodeJson(szExt)
  self.szXGEfunFacebookId = tbExt.facebookId
  self.szXGXMSign = tbExt.sign
  self.szXGXMTimeStamp = tbExt.timestamp
  self.szXGXMUid = tbExt.uid
end
function Sdk:XGGetXMExtraInfo()
  return self.szXGXMUid, self.szXGXMSign, self.szXGXMTimeStamp, IOS and "smjqios" or "smjq"
end
function Sdk:XGOnLogin(bReconnect)
  if not Sdk:IsXgSdk() then
    return
  end
  if not bReconnect then
    Sdk:XGOnEnterGame()
    if self.nCurCreateRoleId == me.dwID then
      Sdk:XGOnRoleCreate()
      Sdk:AppsFlyerTrackEvent("Character", {})
      Sdk:TuneSdkTrackEvent("registration")
    end
    self.nCurCreateRoleId = nil
    self.tbXGFBInviteFriends = {}
    Sdk:XGUpdateEfunFacebookId()
    Sdk:ClearFriendRankCache()
    Sdk:TuneSdkTrackEvent("login")
  end
end
function Sdk:XGUpdateEfunFacebookId()
  if self.szXGEfunFacebookId then
    RemoteServer.SdkRequest("UpdateEfunFacebookId", self.szXGEfunFacebookId)
  end
end
function Sdk:XGOpenNotify(bBeforeLogin)
  Sdk:CallXGMethod("adsWall", tostring(bBeforeLogin and true or false))
end
function Sdk:XGAskFBFriends4Invite()
  Sdk:CallXGMethod("fetchInvitableFriends", "{\"kind\":\"facebook\"}", "OnXGFBInviteFriendsRsp")
end
function Sdk:XGXMTrackEvent(szEvent)
  local tbInfo = {
    roleId = tostring(me.dwID),
    roleLevel = tostring(me.nLevel),
    eventDes = szEvent
  }
  local szParam = Lib:EncodeJson(tbInfo)
  Sdk:CallXGMethod("trackingEvent", szParam)
end
function Sdk:XGXMInvitation()
  local tbInfo = {
    uid = Sdk:GetUid(),
    roleId = tostring(me.dwID),
    roleName = me.szName,
    serverCode = tostring(Sdk:GetServerId())
  }
  local szParam = Lib:EncodeJson(tbInfo)
  Sdk:CallXGMethod("invitation", szParam)
end
function Sdk:XGInviteFriends(tbFriendsInfo)
  if Sdk:HasEfunRank() then
    tbFriendsInfo = {kind = "facebook", friends = tbFriendsInfo}
    local szParam = Lib:EncodeJson(tbFriendsInfo)
    Sdk:CallXGMethod("inviteFriend", szParam, "OnXGInvitedFriendsRsp")
  end
end
function Sdk:XGQueryPlayingFriends()
  Sdk:CallXGMethod("fetchPlayingFriends", "{\"kind\":\"facebook\"}", "OnXGFBPlayingFriendsRsp")
end
function Sdk:XGCheckBindPhoneState()
  local tbParam = {
    userId = Sdk:GetUid()
  }
  local szParam = Lib:EncodeJson(tbParam)
  Sdk:CallXGMethod("checkBindPhoneState", szParam, "OnXGCheckBindPhoneRsp")
end
function Sdk:XGBindPhone()
  Sdk:CallXGMethod("startBindPhone", "", "OnXGBindPhoneRsp")
end
function Sdk:XGBindAccount(szCustomInfo)
  SdkMgr.XgBindAccount(szCustomInfo or "")
end
function Sdk:XGGetUserFBProfile()
  Sdk:CallXGMethod("getUserProfile", "{\"kind\":\"facebook\",\"height\":120,\"width\":120}", "OnXGFBProfileRsp")
end
function Sdk:CallXGMethod(szMethodName, param, szCustomInfo)
  SdkMgr.XgCallMethod(szMethodName, param, szCustomInfo or szMethodName)
end
function Sdk:XGTakeFBInviteAward()
  RemoteServer.SdkRequest("TakeInviteReward")
end
function Sdk:XGShareInfo(szTitle, szPicUrl, szContent, szCaption, szLinkUrl)
  SdkMgr.XgShareInfo(Sdk:GetUid(), tostring(me.dwID), "facebook", szLinkUrl, szTitle, szCaption, szContent, szPicUrl, "")
end
function Sdk:XGSharePhoto(szTitle, szPicUrl, szContent, szCaption, szLinkUrl)
  SdkMgr.XgSharePhoto(Sdk:GetUid(), tostring(me.dwID), "facebook", szLinkUrl, szTitle, szCaption, szContent, szPicUrl, "")
end
function Sdk:XGStartBroadcast()
  if not Sdk:IsEfunHKTW() or not IOS then
    me.CenterMsg("本渠道不支持该功能")
    return false
  end
  Sdk:CallXGMethod("startBroadcast", "", "OnXGIOSBroadcastRsp")
end
function Sdk:XGIsBroadcastShow()
  if not (Sdk:IsEfunHKTW() and IOS) or not GetAppleSystemVersion then
    return false
  end
  local tbVersion = Lib:SplitStr(GetAppleSystemVersion(), "%.")
  local nMainVersion = tonumber(tbVersion[1]) or 0
  if nMainVersion < 10 then
    return false
  end
  return not self.bXGTWHideBroadcast
end
function Sdk:XGOpenUserCenter(szParam)
  SdkMgr.XgOpenUserCenter(szParam or "")
end
function Sdk:XGShowCustomerSupport()
  local tbKinInfo = Kin:GetBaseInfo() or {}
  local tbParam = {
    roleName = me.szName,
    roleLevel = tostring(me.nLevel),
    guild = tbKinInfo.szParam or "",
    serverId = tostring(Sdk:GetServerId()),
    content = ""
  }
  local szParam = Lib:EncodeJson(tbParam)
  Sdk:CallXGMethod("showCustomerSupport", szParam)
end
function Sdk:XGTakeFacebookReward()
  if version_xm and not Sdk:XMIsFacebookClickAwardSend(me) then
    RemoteServer.SdkRequest("TakeXMFacebookReward")
  end
end
function Sdk:XGTakeEvaluateReward()
  if version_xm and not Sdk:XMISEvaluateAwardSend(me) then
    RemoteServer.SdkRequest("TakeXMEvaluateReward")
  end
end
function Sdk:XGSetConfigProperties(tbProperties)
  local szPropertiesJson = Lib:EncodeJson(tbProperties or {})
  Log("XGSetConfigProperties:", szPropertiesJson)
  SdkMgr.XgSetConfigProperties(szPropertiesJson)
end
function Sdk:XGSetVersionProperties()
  if version_th then
    if IOS then
      Sdk:XGSetConfigProperties({
        xgsdkAppId = 17849,
        xgsdkAppKey = "0f97c9a9c7134918b0ab62ad7b631d5f",
        xgsdkBuildNumber = 20170919113425,
        xgsdkBundleId = "com.did.jx",
        xgsdkChannelId = "ios_winnerApple",
        xgsdkPlanId = 7211,
        xgsdkServerVersion = "v1",
        xgsdkAuthUrl = "https://sdksw.winner.in.th:18443",
        xgsdkRechargeUrl = "https://sdksw.winner.in.th:18443",
        xgsdkActivityUrl = "https://sdksw.winner.in.th:18043",
        xgsdkDataUrl = "https://sdkdata.winner.in.th:893"
      })
    elseif ANDROID then
      Sdk:XGSetConfigProperties({
        XgAuthUrl = "http://sdksw.winner.in.th:18888",
        XgRechargeUrl = "http://sdksw.winner.in.th:18888",
        XgActivityUrl = "http://sdksw.winner.in.th:8040",
        XgDataUrl = "http://sdkdata.winner.in.th:89"
      })
    end
  end
  if version_xm then
    if IOS then
      Sdk:XGSetConfigProperties({
        xgsdkAppId = 16818,
        xgsdkAppKey = "c88428aa00274f918128d598d369ccf0",
        xgsdkBuildNumber = 20170907102121,
        xgsdkBundleId = "com.vqw.smjqios",
        xgsdkChannelId = "ios_efunae",
        xgsdkPlanId = 4786,
        xgsdkServerVersion = "v1",
        xgsdkAuthUrl = "https://jxqyjtxgsdk.efunen.com:18443",
        xgsdkRechargeUrl = "https://jxqyjtxgsdk.efunen.com:18443",
        xgsdkActivityUrl = "https://jxqyjtxgsdk.efunen.com:18043",
        xgsdkDataUrl = "https://jxqyjtdata.efunen.com:893",
        channelAppId = ""
      })
    elseif ANDROID then
      Sdk:XGSetConfigProperties({
        XgAuthUrl = "http://jxqyjtxgsdk.efunen.com:18888",
        XgRechargeUrl = "http://jxqyjtxgsdk.efunen.com:18888",
        XgActivityUrl = "http://jxqyjtxgsdk.efunen.com:8040",
        XgDataUrl = "http://jxqyjtdata.efunen.com:89"
      })
    end
  end
end
function Sdk:OnXGShareSucceed(szRetJson)
  Log("Sdk:OnXGShareSucceed", szRetJson)
end
function Sdk:OnXGShareFail(szRetJson)
  Log("Sdk:OnXGShareFail", szRetJson)
end
function Sdk:OnXGGenericCallback(szRetJson)
  Log("Sdk:OnXGGenericCallback", szRetJson)
  local tbRet = Lib:DecodeJson(szRetJson)
  if Sdk[tbRet.customInfo] then
    Sdk[tbRet.customInfo](self, tbRet.code, tbRet.result)
  end
end
function Sdk:OnXGIOSBroadcastRsp(code, tbInfo)
  if tbInfo.state == "开始直播" and code ~= -1 then
    self.bXGTWHideBroadcast = true
    UiNotify.OnNotify(UiNotify.emNOTIFY_XGSDK_CALLBACK, "StartBroadcast")
  elseif tbInfo.state == "结束直播" then
    self.bXGTWHideBroadcast = false
    UiNotify.OnNotify(UiNotify.emNOTIFY_XGSDK_CALLBACK, "EndBroadcast")
  end
end
function Sdk:OnXGFBProfileRsp(code, myInfo)
  if type(myInfo) ~= "table" then
    Sdk:ClearFriendRankCache()
    return
  end
  if myInfo.id ~= self.szXGEfunFacebookId then
    self.szXGEfunFacebookId = myInfo.id
    Sdk:XGUpdateEfunFacebookId()
  end
  Sdk:OnXGFBPlayingFriendsRsp(code, {myInfo}, true)
  Sdk:XGQueryPlayingFriends()
  Sdk:XGAskFBFriends4Invite()
end
function Sdk:OnXGFBPlayingFriendsRsp(code, tbPlayingFriendsInfo, bMyInfo)
  if type(tbPlayingFriendsInfo) ~= "table" then
    Sdk:ClearFriendRankCache()
    return
  end
  local tbPlatFriendsInfo = FriendShip:GetPlatFriendsInfo() or {}
  for _, tbFriend in pairs(tbPlayingFriendsInfo) do
    local tbInfo = {
      szNickName = tbFriend.name or "未知姓名",
      szOpenId = tbFriend.id,
      szHeadSmall = tbFriend.thumbnail,
      szGender = tbFriend.gender
    }
    table.insert(tbPlatFriendsInfo, tbInfo)
  end
  FriendShip:SetPlatFriendsInfo(tbPlatFriendsInfo)
  local tbPlatFriendData = Client:GetDirFileData("PlatFriend" .. Sdk:GetUid())
  tbPlatFriendData.tbFriendsInfo = tbPlatFriendsInfo
  Client:SaveDirFileData("PlatFriend" .. Sdk:GetUid())
  if not bMyInfo then
    Sdk:QueryRankServerInfo()
  end
end
function Sdk:OnXGFBInviteFriendsRsp(code, tbInvitableFriends)
  if type(tbInvitableFriends) ~= "table" then
    Sdk:ClearFriendRankCache()
    return
  end
  self.tbXGFBInviteFriends = tbInvitableFriends or {}
  UiNotify.OnNotify(UiNotify.emNOTIFY_XGSDK_CALLBACK, "FBInviteInfo")
end
function Sdk:XGGetInvitableFriends()
  return self.tbXGFBInviteFriends or {}
end
function Sdk:XGGetFacebookInviteInfo()
  local nInviteDay = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_DAY)
  local tbInvitedIds = Client:GetFlag("FBInviteInfo") or {}
  local nToday = Lib:GetLocalDay()
  if nInviteDay ~= nToday then
    tbInvitedIds = {}
  end
  return tbInvitedIds
end
function Sdk:OnXGInvitedFriendsRsp(code, tbInvitingIds)
  if not tbInvitingIds then
    Sdk:ClearFriendRankCache()
    return
  end
  local tbInvitedIds = Sdk:XGGetFacebookInviteInfo()
  local nPreCount = Lib:CountTB(tbInvitedIds)
  local nCurCount = Lib:CountTB(tbInvitingIds)
  for _, id in pairs(tbInvitingIds) do
    if not tbInvitedIds[id] then
      tbInvitedIds[id] = true
    end
  end
  local nTotalCount = Lib:CountTB(tbInvitedIds)
  Client:SetFlag("FBInviteInfo", tbInvitedIds)
  if nCurCount > 0 then
    me.CenterMsg(string.format("成功邀请%d位好友", nCurCount))
    RemoteServer.SdkRequest("AddInviteFriendsCount", nTotalCount - nPreCount)
  end
end
function Sdk:OnXGCheckBindPhoneRsp(code, tbBindPhoneInfo)
  if tbBindPhoneInfo.state == "ALREADY_BIND" and not Sdk:IsPhoneBinded(me) then
    RemoteServer.SdkRequest("SendBindPhoneReward")
  end
end
function Sdk:OnXGBindPhoneRsp(code, szRet)
  Sdk:XGCheckBindPhoneState()
end
function Sdk:OnXGLoginSuccess(nCode, szAuthInfo)
  Log("Sdk:OnXGLoginSuccess", nCode, szAuthInfo)
  self.szXGAuthInfo = szAuthInfo
  Login:SetAutoLogin(true)
  Login:ConnectGateWay("", szAuthInfo)
  if version_xm then
    Ui:OpenWindow("NoticePanel")
  end
end
function Sdk:OnXGLoginFail(nCode, szMsg, szChannelCode)
  Log("Sdk:OnXGLoginFail", nCode, szMsg, szChannelCode)
  me.MsgBox(string.format("登入失败:\n%s", szMsg or "请稍后再试"), {
    {
      "重登",
      self.Login,
      self
    },
    {"取消"}
  })
end
function Sdk:OnXGLoginCancel(nCode, szMsg)
  me.CenterMsg("您取消了登入")
  Log("Sdk:OnXGLoginCancel", nCode, szMsg)
end
function Sdk:OnXGLogoutFinish(nCode, szMsg)
  Log("Sdk:OnXGLogoutFinish", nCode, szMsg)
  self.szXGAuthInfo = nil
  Ui:OnLogoutFinish()
end
function Sdk:OnXGPaySuccess(szPayResult)
  Log("Sdk:OnXGPaySuccess", szPayResult)
  self.nNextPayTime = nil
  local tbResult = Lib:DecodeJson(szPayResult) or {}
  if not Lib:IsEmptyStr(tbResult.gameTradeNo) then
    RemoteServer.RechargeRequestlock(tbResult.gameTradeNo)
  end
  local szTips = "支付成功, 请注意查收"
  if not Lib:IsEmptyStr(tbResult.channelMsg) then
    szTips = tbResult.channelMsg
  end
  me.CenterMsg(szTips)
  if self.tbLastPayInfo then
    Sdk:AppsFlyerTrackEvent("payment", self.tbLastPayInfo)
    Sdk:TuneSdkTrackEvent("purchase", self.tbLastPayInfo)
  end
end
function Sdk:OnXGPayFail(szPayResult)
  Log("Sdk:OnXGPayFail", szPayResult)
  self.nNextPayTime = nil
  if Sdk:XGSurportThridPay() then
    return
  end
  local tbResult = Lib:DecodeJson(szPayResult) or {}
  local szTips = tbResult.code or ""
  if not Lib:IsEmptyStr(tbResult.channelMsg) then
    szTips = tbResult.channelMsg
  end
  me.CenterMsg(string.format("支付失败:%s", szTips or ""))
end
function Sdk:OnXGPayCancel(szPayResult)
  Log("Sdk:OnXGPayCancel", szPayResult)
  self.nNextPayTime = nil
  me.CenterMsg("您取消了支付")
end
function Sdk:OnXGPayOthers(szPayResult)
  Log("Sdk:OnXGPayOthers", szPayResult)
end
function Sdk:OnXGPayProgress(szPayResult)
  Log("Sdk:OnXGPayProgress", szPayResult)
end
local tbXGExchangeTips = {
  [0] = "兑换成功",
  [1000] = "对不起，礼包码无效",
  [1001] = "对不起，用户不存在",
  [1002] = "对不起，活动未开始",
  [1003] = "对不起，活动过期",
  [1004] = "对不起，礼包码只能在指定区服使用",
  [1005] = "对不起，用户不能重复领取礼包",
  [1006] = "对不起，您领取次数已超过限制",
  [1007] = "对不起，该批次礼包码兑换次数已经到达上限",
  [1008] = "对不起，该礼包码在同一互斥组",
  [1009] = "对不起，您没有通过礼包码要求的关卡",
  [1010] = "对不起，您的等级低于领取礼包最小等级要求",
  [1011] = "对不起，您的等级高于领取礼包最大等级要求",
  [1012] = "对不起，该礼包无法在该渠道使用",
  [2000] = "对不起，游戏服务器异常",
  [2001] = "对不起，游戏服务器返回发放失败",
  [2002] = "对不起，获取用户信息失败",
  [3000] = "对不起，兑换服务器异常",
  [3001] = "对不起，系统错误",
  [3002] = "对不起，发生未知网络错误"
}
function Sdk:OnXGExchangeGiftCodeFinish(szRetJson)
  Log("Sdk:OnXGExchangeGiftCodeFinish", szRetJson)
  local tbRet = Lib:DecodeJson(szRetJson) or {}
  local szMsg = tbXGExchangeTips[tonumber(tbRet.code)] or tbRet.msg
  if szMsg then
    me.CenterMsg(szMsg)
  end
end
function Sdk:OnXGExtraRsp(szRspType, ...)
  Log("Sdk:OnXGExtraRsp", szRspType, ...)
end
function Sdk:AppsFlyerTrackEvent(szEventName, eventValue)
  Log("AppsFlyerTrackEvent")
  Lib:Tree({szEventName, eventValue})
  if type(eventValue) == "table" then
    SdkMgr.AppsFlyerTrackRichEvent(szEventName, eventValue)
  else
    Log("AppsFlyerTrackEvent Error")
  end
end
function Sdk:TuneSdkTrackEvent(szEventName, tbEventValue)
  if not USE_TUNE_SDK then
    return
  end
  Log("TuneSdkTrackEvent", szEventName)
  Lib:Tree({szEventName, tbEventValue})
  SdkMgr.TuneSdkTrackEvent(szEventName, me.szName or "", tostring(me.dwID or ""), Sdk:GetUid(), tbEventValue or {})
end
function Sdk:QueryASMInfo()
  if not Sdk:IsMsdk() or not IOS then
    return
  end
  local tbVersion = Lib:SplitStr(GetAppleSystemVersion(), "%.")
  local nMainVersion = tonumber(tbVersion[1]) or 0
  if nMainVersion < 9 then
    Log("Ignore QueryASMInfo for iOS", nMainVersion)
    return
  end
  if Client:GetFlag("ASMReported", -1) then
    return
  end
  SdkMgr.QueryASMInfo()
end
local nASMUnknowErr = 0
local nASMLimited = 1
function Sdk:OnQueryASMNotify(szJsonRet)
  Log("Sdk:OnQueryASMNotify", szJsonRet)
  local nASMRsp = tonumber(szJsonRet)
  if nASMRsp then
    if nASMRsp == nASMLimited then
      Client:SetFlag("ASMReported", 1, -1)
    end
    return
  end
  self.szASMJson2Report = szJsonRet
end
function Sdk:ReprotASMInfo()
  if not self.szASMJson2Report then
    return
  end
  RemoteServer.SdkRequest("ReprotASMInfo", self.szASMJson2Report)
  self.szASMJson2Report = nil
  Client:SetFlag("ASMReported", true, -1)
end
