local tbSelect = Ui:CreateClass("PartnerGrallerySelect")
local tbUi = Ui:CreateClass("PartnerGrallery")
tbUi.COUNT_PRE_ROW = 5
tbUi.CUR_PARTNER_LIST = 1
tbUi.Cur_EXT_ATTRIB_LIST = 2
tbUi.nCurType = tbUi.CUR_PARTNER_LIST
function tbUi:Update()
  self:UpdatePartnerList()
end
function tbUi:UpdatePartnerList()
  self:UpdateCurPartnerList()
  Partner:ClearGralleryRedPoint()
  local tbAllPartnerBaseInfo = Partner:GetAllPartnerBaseInfo()
  local nRowCount = math.ceil(#self.tbCurPartnerList / self.COUNT_PRE_ROW)
  local tbCurList = {
    {}
  }
  local nLastQuality
  for i = 1, #self.tbCurPartnerList do
    local nPartnerId = self.tbCurPartnerList[i]
    local tbBaseInfo = tbAllPartnerBaseInfo[nPartnerId]
    local tbCur = tbCurList[#tbCurList]
    if #tbCur >= self.COUNT_PRE_ROW then
      tbCur = {}
      table.insert(tbCurList, tbCur)
    end
    nLastQuality = tbBaseInfo.nQualityLevel
    table.insert(tbCur, nPartnerId)
  end
  local function fnSetItem(ItemObj, index)
    self:SetItem(ItemObj, index, tbCurList)
  end
  self.PartnerList:Update(tbCurList, fnSetItem)
end
function tbUi:SetItem(ItemObj, index, tbCurList)
  local tbRPInfo = Partner:GetGralleryRedPoint() or {}
  local tbAllPartnerBaseInfo = Partner:GetAllPartnerBaseInfo()
  local tbInfo = tbCurList[index]
  local function fnSetCurPartner(ItemObj)
    print("click partner:" .. ItemObj.nPartnerId)
    Ui:OpenWindow("PartnerDetail", nil, nil, nil, ItemObj.nPartnerId, self.tbCurPartnerList)
  end
  for i = 1, #tbInfo do
    local nPartnerId = tbInfo[i]
    local tbBaseInfo = tbAllPartnerBaseInfo[nPartnerId]
    ItemObj["PartnerHead" .. i]:SetPartnerById(nPartnerId)
    ItemObj["PartnerHead" .. i].pPanel:SetActive("GrowthLevel", false)
    ItemObj.pPanel:SetActive("P" .. i, true)
    ItemObj.pPanel:Label_SetText("Name" .. i, Partner:GetPartnerAwareness(me, nPartnerId) == 1 and tbBaseInfo.szName .. "·觉醒" or tbBaseInfo.szName)
    local nHas = me.GetUserValue(Partner.PARTNER_HAS_GROUP, nPartnerId)
    ItemObj.pPanel:SetActive("HasPartner" .. i, nHas == 1)
    ItemObj["BtnClick" .. i].nPartnerId = nPartnerId
    ItemObj["BtnClick" .. i].pPanel.OnTouchEvent = fnSetCurPartner
    ItemObj.pPanel:SetActive("RP" .. i, tbRPInfo[nPartnerId] and true or false)
  end
  for i = #tbInfo + 1, self.COUNT_PRE_ROW do
    ItemObj.pPanel:SetActive("P" .. i, false)
  end
end
function tbUi:UpdateCurPartnerList()
  local tbAllPartner = me.GetAllPartner()
  self.tbAllPartner = {}
  for _, tbPartnerInfo in pairs(tbAllPartner) do
    self.tbAllPartner[tbPartnerInfo.nTemplateId] = true
  end
  if self.tbCurPartnerList and #self.tbCurPartnerList > 0 then
    return self.tbCurPartnerList
  end
  self.tbCurPartnerList = self.tbCurPartnerList or {}
  local tbAllPartnerBaseInfo = Partner:GetAllPartnerBaseInfo()
  for nPartnerId, tbBaseInfo in pairs(tbAllPartnerBaseInfo) do
    local szShowTimeFrame = (Partner.tbAllPartnerInfo[nPartnerId] or {}).szShowTimeFrame
    if not szShowTimeFrame or szShowTimeFrame == "" or GetTimeFrameState(szShowTimeFrame) == 1 then
      table.insert(self.tbCurPartnerList, nPartnerId)
    end
  end
  local function fnCmp(a, b)
    local nQualityLevelA = (tbAllPartnerBaseInfo[a] or {}).nQualityLevel or 0
    local nQualityLevelB = (tbAllPartnerBaseInfo[b] or {}).nQualityLevel or 0
    if nQualityLevelA ~= nQualityLevelB then
      return nQualityLevelA < nQualityLevelB
    end
    return b < a
  end
  table.sort(self.tbCurPartnerList, fnCmp)
end
