local tbTimeCase = Item:GetClass("TimeCase");

function tbTimeCase:LoadSetting()
	self.tbAllCaseInfo = {};

	local tbFileData = Lib:LoadTabFile("Setting/Item/Other/TimeCase.tab", {TemplateId = 1, ServerOpenDay = 1});
	for _, tbInfo in pairs(tbFileData) do
		self.tbAllCaseInfo[tbInfo.TemplateId] = tbInfo;
	end	
end

tbTimeCase:LoadSetting();

function tbTimeCase:OnUse(pItem)
	local nRet, szMsg = self:CheckUsable(pItem);
	if nRet ~= 1 then
		me.CenterMsg(szMsg);
		return 0;
	end	
	
	local nReturn = Item:GetClass("RandomItem"):OnUse(pItem);
	if nReturn ~= 1 then
		return 0;
	end

	return 1;
end


function tbTimeCase:CheckUsable(pItem)
	local tbItemInfo = self.tbAllCaseInfo[pItem.dwTemplateId];
	if not tbItemInfo then
		Log("[tbTimeCase] OnUse ERR ?? tbKey is nil !!", me.szName, me.dwID, pItem.szName, pItem.dwTemplateId);
		return 0, "很遺憾,系統檢測到該道具異常,暫時無法使用!";
	end

	local nServerOpenDay = Lib:GetServerOpenDay();
	if tbItemInfo.ServerOpenDay > nServerOpenDay then
		return 0, "尚未到開啟的時間";
	end	

	return 1;
end