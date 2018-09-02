Require("CommonScript/Item/Class/Equip.lua")
local tbWaiyi = Item:GetClass("waiyi")
local tbEquip = Item:GetClass("equip")
function tbWaiyi:GetTip(pEquip, pPlayer, bIsCompare)
  return ""
end
function tbWaiyi:GetUseSetting(nTemplateId, nItemId)
  local tbEquipList = me.GetEquips(1)
  local tbOpt = {}
  return {}
end
local tbWaiyiEx = Item:GetClass("waiyi_exchange")
function tbWaiyiEx:OnUse(it)
  local nTargetId = Item.tbEquipExchange:GetTargetItem(it.dwTemplateId)
  if nTargetId then
    local tbBaseProp = KItem.GetItemBaseProp(nTargetId)
    if tbBaseProp.nFactionLimit > 0 and me.nFaction ~= tbBaseProp.nFactionLimit then
      me.CenterMsg(string.format("该道具只能%s门派方可使用", Faction:GetName(tbBaseProp.nFactionLimit)))
      return 0
    end
    Item.tbEquipExchange:DoExchange(me, it.dwId)
  end
  return 0
end
function tbWaiyiEx:OnClientUse(it)
  local nItemId = it.dwId
  self:UseConfirm(nItemId)
  return 1
end
function tbWaiyiEx:UseConfirm(nItemId, bConfirm)
  local pItem = me.GetItemInBag(nItemId)
  if not pItem then
    return
  end
  local nTargetId, nTimeOut = Item.tbEquipExchange:GetTargetItem(pItem.dwTemplateId)
  if not bConfirm and nTimeOut > 0 then
    me.MsgBox("使用后您将获得一件[FFFE0D]限时外装[-]并开始计算使用时间，请问是否使用?", {
      {
        "确定",
        self.UseConfirm,
        self,
        nItemId,
        true
      },
      {"取消"}
    })
    return
  end
  RemoteServer.UseItem(nItemId)
  return
end
function tbWaiyiEx:GetUseSetting(nTemplateId, nItemId)
  local tbRet = {szFirstName = "使用", fnFirst = "UseItem"}
  local tbInfo = Gift:GetMailGiftItemInfo(nTemplateId)
  if not tbInfo then
    return tbRet
  end
  if me.GetVipLevel() < tbInfo.tbData.nVip then
    return tbRet
  end
  tbRet = {
    szFirstName = "赠送",
    fnFirst = function()
      Ui:OpenWindow("GiftSystem")
      Ui:CloseWindow("ItemTips")
    end,
    szSecondName = "使用",
    fnSecond = "UseItem"
  }
  return tbRet
end
function tbWaiyiEx:GetIntrol(nTemplateId)
  local nTargetId = Item.tbEquipExchange:GetTargetItem(nTemplateId)
  if nTargetId then
    local tbBaseProp = KItem.GetItemBaseProp(nTargetId)
    if tbBaseProp.nFactionLimit > 0 and me.nFaction ~= tbBaseProp.nFactionLimit then
      local tbBaseOld = KItem.GetItemBaseProp(nTemplateId)
      local szOldTip = tbBaseOld.szIntro
      szOldTip = string.gsub(szOldTip, "\\n", "\n")
      return string.gsub(szOldTip, "FFFE0D", "FF0000", 1)
    end
  end
end
