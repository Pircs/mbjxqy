local tbUi = Ui:CreateClass("HouseDecorationPanel")
tbUi.nLogicPosCell = 0.01
tbUi.green_res = "Scenes/Meshes/sn_jiayuan/Prefabs/fangzhi01_01.prefab"
tbUi.red_res = "Scenes/Meshes/sn_jiayuan/Prefabs/fangzhi01_02.prefab"
tbUi.tbGreen = {
  0,
  1,
  0
}
tbUi.tbRed = {
  1,
  0,
  0
}
tbUi.TYPE_NORMAL = 1
tbUi.TYPE_HAS_SCALER = 2
tbUi.tbPos = {
  [tbUi.TYPE_NORMAL] = {
    {-70, 27},
    {0, 48},
    {70, 27}
  },
  [tbUi.TYPE_HAS_SCALER] = {
    {-112, 0},
    {-45, 45},
    {45, 45},
    {112, 0}
  }
}
tbUi.tbAllBtn = {
  "BtnSure",
  "BtnCannel",
  "BtnRotate",
  "BtnEnlarge"
}
tbUi.tbBtn = {
  [tbUi.TYPE_NORMAL] = {
    "BtnSure",
    "BtnCannel",
    "BtnRotate"
  },
  [tbUi.TYPE_HAS_SCALER] = {
    "BtnSure",
    "BtnCannel",
    "BtnRotate",
    "BtnEnlarge"
  }
}
tbUi.szDirRes = "Scenes/Meshes/sn_jiayuan/Prefabs/fangzhi01_jiantou01_01.prefab"
function tbUi:OnOpen()
  self.pPanel:SetActive("PutSetting", false)
  self.pPanel:SetActive("ScaleSetting", false)
  self.bIsInLivingRoom = House:IsInLivingRoom(me)
  self.pPanel:SetActive("Other", not self.bIsInLivingRoom and true or false)
  self.pPanel:ChangePosition("BtnOut", self.bIsInLivingRoom and 491 or 499, self.bIsInLivingRoom and -281 or -196, 0)
end
function tbUi:OnOpenEnd()
  if not self.bIsInLivingRoom then
    self:UpdateFurniture()
    self:UpdateComfort()
  end
  if not Client:GetFlag("DecorationGuide") then
    Client:SetFlag("DecorationGuide", 1)
    Ui:OpenWindow("HomeSettingGuide")
  end
end
function tbUi:UpdateFurniture()
  if self.bIsInLivingRoom then
    return
  end
  self.tbFurniture = {}
  for nTemplateId, nCount in pairs(House.tbFurniture or {}) do
    table.insert(self.tbFurniture, {nTemplateId, nCount})
  end
  local m, x, y = me.GetWorldPos()
  table.sort(self.tbFurniture, function(a, b)
    local tbA, nAFId = House:GetFurnitureInfo(a[1])
    local tbB, nBFId = House:GetFurnitureInfo(b[1])
    local bACanPut = House:CheckCanPutFurnitureCommon(me.nMapTemplateId, x, y, 0, a[1])
    local bBCanPut = House:CheckCanPutFurnitureCommon(me.nMapTemplateId, x, y, 0, b[1])
    if bACanPut ~= bBCanPut then
      return bACanPut
    end
    if tbA.nLevel ~= tbB.nLevel then
      return tbA.nLevel > tbB.nLevel
    end
    if tbA.nType ~= tbB.nType then
      return tbA.nType < tbB.nType
    end
    if tbA.nComfortValue ~= tbB.nComfortValue then
      return tbA.nComfortValue > tbB.nComfortValue
    end
    return nAFId < nBFId
  end)
  local function fnSetItem(itemObj, index)
    local tbInfo = self.tbFurniture[index]
    if tbInfo then
      itemObj:SetItemByTemplate(tbInfo[1], tbInfo[2])
      itemObj.fnClick = itemObj.DefaultClick
      local bCanPut = House:CheckCanPutFurnitureCommon(me.nMapTemplateId, x, y, 0, tbInfo[1])
      if not bCanPut then
        itemObj.pPanel:Sprite_SetSprite("CDLayer", "itemframeDisable")
      end
      itemObj.pPanel:SetActive("CDLayer", not bCanPut)
    else
      itemObj:Clear()
      itemObj.fnClick = nil
    end
  end
  self.ScrollView:Update(math.max(#self.tbFurniture, 10), fnSetItem)
end
function tbUi:UpdateComfort()
  if self.bIsInLivingRoom then
    return
  end
  local nComfortValue = House:GetComfortableShowInfo()
  local nComfortLevel = House:CalcuComfortLevel(nComfortValue)
  local tbComfortSetting = House:GetComfortSetting(nComfortLevel)
  self.pPanel:Label_SetText("ComfortableLevel", string.format("[92D2FF]舒适等级：[-]%d级", nComfortLevel))
  local tbNextComfortSetting = House:GetComfortSetting(nComfortLevel + 1)
  local nNextComfort = tbNextComfortSetting and tbNextComfortSetting.nComfort or tbComfortSetting.nComfort
  self.pPanel:Label_SetText("ComfortableValue", string.format("%d / %d", nComfortValue, nNextComfort))
  self.pPanel:Sprite_SetFillPercent("Bar", math.min(nComfortValue / nNextComfort, 1))
end
function tbUi:ChangeObjPos(nX, nY, nRotation)
  if not self.tbOptDecoration then
    return
  end
  local pRep = Ui.Effect.GetObjRepresent(self.tbOptDecoration.nRepId)
  if not pRep then
    return
  end
  nX, nY = Decoration:GetRealPos(self.tbOptDecoration.nTemplateId, nX, nY, nRotation)
  self.tbOptDecoration.nX = nX
  self.tbOptDecoration.nY = nY
  self.tbOptDecoration.nRotation = nRotation
  pRep:SetLogicPos(nX, nY)
  pRep:SetRotation(0, math.floor(nRotation / 90) % 4 * 90, 0)
  local bCanPut = Decoration:CheckCanUseDecoration(me.nMapId, nX, nY, nRotation, self.tbOptDecoration.nTemplateId)
  self.tbOptDecoration.bCanPut = bCanPut
  self.pPanel:Sprite_SetSprite("PutSetting", bCanPut and "FurnitureGhangeBg" or "FurnitureGhangeBg2")
  self.pPanel:Sprite_SetSprite("PutSetting2", bCanPut and "FurnitureGhangeBg" or "FurnitureGhangeBg2")
  self.pPanel:Button_SetEnabled("BtnSure", bCanPut and true or false)
  self.pPanel:Sprite_SetGray("BtnSure", not bCanPut and true or false)
  local tbColor = bCanPut and self.tbGreen or self.tbRed
  self:SetRimColor(self.tbOptDecoration.nTemplateId, pRep, tbColor[1], tbColor[2], tbColor[3], 0.2)
end
function tbUi:CheckInEdge(nX, nY)
  local nBarrier = GetBarrierInfo(me.nMapId, nX, nY)
  if nBarrier ~= 200 then
    return false
  end
  if GetBarrierInfo(me.nMapId, nX + Decoration.CELL_LOGIC_WIDTH, nY) ~= 200 and GetBarrierInfo(me.nMapId, nX - Decoration.CELL_LOGIC_WIDTH, nY) == 200 then
    return true, true
  end
  if GetBarrierInfo(me.nMapId, nX, nY + Decoration.CELL_LOGIC_HEIGHT) ~= 200 and GetBarrierInfo(me.nMapId, nX, nY - Decoration.CELL_LOGIC_HEIGHT) == 200 then
    return true, false
  end
  return false
end
function tbUi:SetRimColor(nDecorationId, pRep, nR, nG, nB, nA)
  local tbTemplate = Decoration.tbAllTemplate[nDecorationId]
  pRep:SetRimColor(tbTemplate.szResPath, nR, nG, nB, nA)
  if self.tbOptDecoration and self.tbOptDecoration.bShowDir == 1 then
    pRep:SetRimColor(self.szDirRes, nR, nG, nB, 1)
  end
end
function tbUi:ClickObj(nX, nY)
  local bError = false
  if nX <= 0 or nY <= 0 then
    bError = true
  end
  if not self.nSpaceX or not self.nSpaceY then
    self.nSpaceX = self.tbOptDecoration.nX - nX
    self.nSpaceY = self.tbOptDecoration.nY - nY
  end
  nX = self.nSpaceX + nX
  nY = self.nSpaceY + nY
  if not bError then
    self.nCacheX, self.nCacheY = nX, nY
  else
    nX = self.nCacheX or nX
    nY = self.nCacheY or nY
  end
  nX, nY = Decoration:GetRealPos(self.tbOptDecoration.nTemplateId, nX, nY, self.tbOptDecoration.nRotation)
  local bInEdge, bIsX = self:CheckInEdge(self.tbOptDecoration.nX, self.tbOptDecoration.nY)
  if bInEdge then
    nX = bIsX and nX > self.tbOptDecoration.nX and self.tbOptDecoration.nX or nX
    nY = not bIsX and nY > self.tbOptDecoration.nY and self.tbOptDecoration.nY or nY
  end
  self:ChangeObjPos(nX, nY, self.tbOptDecoration.nRotation)
end
tbUi.nUiHeight = 250
function tbUi:OnSimpleTap(...)
  self:SimpleTap(...)
end
function tbUi:SimpleTap(nRepId)
  local nId, tbRepInfo = Decoration:GetRepInfoByRepId(nRepId)
  local tbMainSeatInfo = House.tbMainSeatInfo[me.nMapTemplateId] or {-1}
  if tbMainSeatInfo[1] == tbRepInfo.nTemplateId then
    return
  end
  if self.tbOptDecoration then
    if self.tbOptDecoration.nRepId ~= nRepId and self.tbOptDecoration.bCanPut then
      self.tbOnClick.BtnSure(self)
    end
    return
  end
  tbRepInfo.bTest = true
  self.tbOptDecoration = {
    nId = nId,
    nRepId = nRepId,
    nTemplateId = tbRepInfo.nTemplateId,
    nX = tbRepInfo.nX,
    nY = tbRepInfo.nY,
    nSX = tbRepInfo.nSX,
    nSY = tbRepInfo.nSY,
    nRotation = tbRepInfo.nRotation,
    nMapId = tbRepInfo.nMapId
  }
  Decoration:SetObstacle(tbRepInfo.nMapId, tbRepInfo.nX, tbRepInfo.nY, tbRepInfo.nRotation, tbRepInfo.nTemplateId, true, true)
  self.pPanel:SetActive("PutSetting", true)
  self.pPanel:ObjRep_SetFollow("PutSetting", self.tbOptDecoration.nRepId)
  local nSXMin = Decoration:GetScaleSetting(tbRepInfo.nTemplateId)
  self:UpdateBtnType(nSXMin and self.TYPE_HAS_SCALER or self.TYPE_NORMAL)
  local bIsInLivingRoom = House:IsInLivingRoom(me)
  self.pPanel:Button_SetEnabled("BtnCannel", not bIsInLivingRoom)
  self.pPanel:Sprite_SetGray("BtnCannel", bIsInLivingRoom and true or false)
  local pRep = Ui.Effect.GetObjRepresent(self.tbOptDecoration.nRepId)
  pRep:SetPenetrateClick(true)
  local tbDecoration = Decoration.tbAllTemplate[tbRepInfo.nTemplateId]
  pRep:SetUiLogicPos(0, self.nUiHeight, 0)
  pRep:SetMapColliderActive(false)
  if tbDecoration.bShowDir == 1 then
    pRep:AddEffectRes(self.szDirRes, 0)
    pRep:SetEffectPosition(self.szDirRes, -1 * tbDecoration.nWidth * Decoration.CELL_LOGIC_HEIGHT * self.nLogicPosCell / 2, 0, 0)
    local nScale = tbDecoration.nWidth / 2
    pRep:SetEffectLogicSize(self.szDirRes, nScale / self.nLogicPosCell, 1 / self.nLogicPosCell, nScale / self.nLogicPosCell)
    self.tbOptDecoration.bShowDir = tbDecoration.bShowDir
  end
  self:ChangeObjPos(self.tbOptDecoration.nX, self.tbOptDecoration.nY, self.tbOptDecoration.nRotation)
end
function tbUi:UpdateBtnType(nType)
  local tbBtn = {}
  local tbPos = self.tbPos[nType]
  for i, szBtn in pairs(self.tbBtn[nType]) do
    tbBtn[szBtn] = true
    self.pPanel:ChangePosition(szBtn, tbPos[i][1], tbPos[i][2])
  end
  for _, szBtn in pairs(self.tbAllBtn) do
    self.pPanel:SetActive(szBtn, tbBtn[szBtn] and true or false)
  end
  self.pPanel:SetActive("ScaleSetting", false)
end
function tbUi:LongTapStart(nRepId, nSX, nSY)
end
function tbUi:TouchUp(nRepId)
  self.nSpaceX = nil
  self.nSpaceY = nil
end
function tbUi:OnPutDecoration(...)
  self:OnPutDecorationFunc(...)
end
function tbUi:OnPutDecorationFunc(nItemTemplateId)
  if self.tbOptDecoration then
    me.CenterMsg("先摆放好当前的家具吧！")
    return
  end
  local tbFurniture = House:GetFurnitureInfo(nItemTemplateId)
  if not tbFurniture then
    me.CenterMsg("此家具好像出了点问题！")
    return
  end
  local m, x, y = me.GetWorldPos()
  self.tbOptDecoration = {
    nItemTId = nItemTemplateId,
    nTemplateId = tbFurniture.nDecorationId,
    nX = x,
    nY = y,
    nRotation = Decoration:GetNextRotation(tbFurniture.nDecorationId),
    nMapId = m
  }
  Decoration:CreateClientRep(self.tbOptDecoration, true)
  local nSXMin = Decoration:GetScaleSetting(tbFurniture.nDecorationId)
  self:UpdateBtnType(nSXMin and self.TYPE_HAS_SCALER or self.TYPE_NORMAL)
  self.pPanel:SetActive("PutSetting", true)
  self.pPanel:ObjRep_SetFollow("PutSetting", self.tbOptDecoration.nRepId)
  local pRep = Ui.Effect.GetObjRepresent(self.tbOptDecoration.nRepId)
  pRep:SetPenetrateClick(true)
  local tbDecoration = Decoration.tbAllTemplate[tbFurniture.nDecorationId]
  pRep:SetUiLogicPos(0, math.max(tbDecoration.nHeight + 50, 50), 0)
  if tbDecoration.bShowDir == 1 then
    pRep:AddEffectRes(self.szDirRes, 0)
    pRep:SetEffectPosition(self.szDirRes, -1 * tbDecoration.nWidth * Decoration.CELL_LOGIC_HEIGHT * self.nLogicPosCell / 2, 0, 0)
    local nScale = tbDecoration.nWidth / 2
    pRep:SetEffectLogicSize(self.szDirRes, nScale / self.nLogicPosCell, 1 / self.nLogicPosCell, nScale / self.nLogicPosCell)
    self.tbOptDecoration.bShowDir = tbDecoration.bShowDir
  end
  self:ChangeObjPos(self.tbOptDecoration.nX, self.tbOptDecoration.nY, self.tbOptDecoration.nRotation)
end
function tbUi:OnLeaveMap()
  self:CancelOpt()
  House:ExitDecorationMode()
end
function tbUi:OnSyncFurniture()
  self:UpdateFurniture()
end
function tbUi:OnSyncSwitchPlace()
  self:UpdateFurniture()
  if not self.tbOptDecoration then
    return
  end
  local m, x, y = me.GetWorldPos()
  if not House:CheckInSameRange(me.nMapTemplateId, x, y, self.tbOptDecoration.nX, self.tbOptDecoration.nY) then
    self:CancelOpt()
  end
end
function tbUi:CancelOpt()
  self.pPanel:SetActive("PutSetting", false)
  if not self.tbOptDecoration then
    return
  end
  local tbOptDecoration = self.tbOptDecoration
  self.tbOptDecoration = nil
  Ui.Effect.RemoveObjRepresent(tbOptDecoration.nRepId)
  if tbOptDecoration.nId then
    local tbRep = Decoration.tbClientDecoration[tbOptDecoration.nId]
    Decoration:OnSyncDecoration(tbRep.nMapId, tbOptDecoration.nId, Decoration:GetSyncInfo(tbRep))
  end
  Decoration:ClearClientTempObs()
end
function tbUi:PackupFurniture()
  self.pPanel:SetActive("PutSetting", false)
  if not self.tbOptDecoration then
    return
  end
  if not self.tbOptDecoration.nId then
    self:CancelOpt()
    return
  end
  Ui.Effect.RemoveObjRepresent(self.tbOptDecoration.nRepId)
  RemoteServer.PackupFurniture(self.tbOptDecoration.nId)
  self.tbOptDecoration = nil
  Decoration:ClearClientTempObs()
end
function tbUi:OnDeleteDecoration(nId)
  if not (self.tbOptDecoration and self.tbOptDecoration.nId) or self.tbOptDecoration.nId ~= nId then
    return
  end
  me.CenterMsg("该家具已被其他房客挪动")
  self.pPanel:SetActive("PutSetting", false)
  self.tbOptDecoration = nil
  Decoration:ClearClientTempObs()
end
function tbUi:SetScale(fXValue, fYValue)
  if fXValue then
    self.tbOptDecoration.nSX = (self.tbOptDecoration.nSXMax - self.tbOptDecoration.nSXMin) * fXValue + self.tbOptDecoration.nSXMin
  end
  if fYValue then
    self.tbOptDecoration.nSY = (self.tbOptDecoration.nSYMax - self.tbOptDecoration.nSYMin) * fYValue + self.tbOptDecoration.nSYMin
  end
  local pRep = Ui.Effect.GetObjRepresent(self.tbOptDecoration.nRepId)
  pRep:SetScale(self.tbOptDecoration.nSX, 1, self.tbOptDecoration.nSY)
end
function tbUi:UpdateScalePanel(bOpen)
  if not bOpen then
    self.pPanel:SetActive("ScaleSetting", false)
    return
  end
  self.tbOptDecoration.nSX = self.tbOptDecoration.nSX or 1
  self.tbOptDecoration.nSY = self.tbOptDecoration.nSY or 1
  self.tbOptDecoration.nSXMin, self.tbOptDecoration.nSXMax, self.tbOptDecoration.nSYMin, self.tbOptDecoration.nSYMax = Decoration:GetScaleSetting(self.tbOptDecoration.nTemplateId)
  if not self.tbOptDecoration.nSXMin then
    Log("[HouseDecorationPanel] Decoration:GetScaleSetting return nil !!", self.tbOptDecoration.nTemplateId)
    return
  end
  local nCurSXValue = (self.tbOptDecoration.nSX - self.tbOptDecoration.nSXMin) / (self.tbOptDecoration.nSXMax - self.tbOptDecoration.nSXMin)
  local nCurSYValue = (self.tbOptDecoration.nSY - self.tbOptDecoration.nSYMin) / (self.tbOptDecoration.nSYMax - self.tbOptDecoration.nSYMin)
  self.pPanel:SetActive("ScaleSetting", true)
  self.pPanel:SetActive("PutSetting", false)
  self.pPanel:SliderBar_SetValue("BtnSX", nCurSXValue)
  self.pPanel:SliderBar_SetValue("BtnSY", nCurSYValue)
end
function tbUi:OnClose()
  self:CancelOpt()
  House:ExitDecorationMode()
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_REPOBJSIMPLETAP,
      self.OnSimpleTap
    },
    {
      UiNotify.emNOTIFY_REPOBJLONGTAPSTART,
      self.LongTapStart
    },
    {
      UiNotify.emNOTIFY_REPOBJTOUCHUP,
      self.TouchUp
    },
    {
      UiNotify.emNOTIFY_PUT_DECORATION,
      self.OnPutDecoration
    },
    {
      UiNotify.emNOTIFY_MAP_LEAVE,
      self.OnLeaveMap
    },
    {
      UiNotify.emNOTIFY_SYNC_FURNITURE,
      self.OnSyncFurniture
    },
    {
      UiNotify.emNOTIFY_SYNC_SWITCH_PLACE,
      self.OnSyncSwitchPlace
    },
    {
      UiNotify.emNOTIFY_DELETE_DECORATION,
      self.OnDeleteDecoration
    },
    {
      UiNotify.emNOTIFY_SYNC_MAP_FURNITURE,
      self.UpdateComfort
    }
  }
  return tbRegEvent
end
tbUi.tbOnDrag = tbUi.tbOnDrag or {}
function tbUi.tbOnDrag:PutSetting(szWnd, x, y)
  if not self.tbOptDecoration.tbStartScreenPos then
    self.nSpaceX = nil
    self.nSpaceY = nil
    local tbSP = Ui.CameraMgr.GetScreenDirection(self.tbOptDecoration.nX, self.tbOptDecoration.nY)
    self.tbOptDecoration.tbStartScreenPos = {
      tbSP.x,
      tbSP.y
    }
  end
  self.tbOptDecoration.tbStartScreenPos[1] = self.tbOptDecoration.tbStartScreenPos[1] + x
  self.tbOptDecoration.tbStartScreenPos[2] = self.tbOptDecoration.tbStartScreenPos[2] + y
  local tbSCPos = Ui.CameraMgr.GetSceneDirection(self.tbOptDecoration.tbStartScreenPos[1] + Ui.Screen.width / 2, self.tbOptDecoration.tbStartScreenPos[2] + Ui.Screen.height / 2)
  self:ClickObj(tbSCPos.x, tbSCPos.y)
end
function tbUi.tbOnDrag:BtnSX()
  local fValue = self.pPanel:SliderBar_GetValue("BtnSX")
  self:SetScale(fValue, nil)
end
function tbUi.tbOnDrag:BtnSY()
  local fValue = self.pPanel:SliderBar_GetValue("BtnSY")
  self:SetScale(nil, fValue)
end
tbUi.tbOnDragEnd = tbUi.tbOnDragEnd or {}
function tbUi.tbOnDragEnd:PutSetting(szWnd)
  self.tbOptDecoration.tbStartScreenPos = nil
end
function tbUi.tbOnDragEnd:BtnSX()
  local fValue = self.pPanel:SliderBar_GetValue("BtnSX")
  self:SetScale(fValue, nil)
end
function tbUi.tbOnDragEnd:BtnSY()
  local fValue = self.pPanel:SliderBar_GetValue("BtnSY")
  self:SetScale(nil, fValue)
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnDetails()
  Ui:OpenWindow("HouseComfortablePanle")
end
function tbUi.tbOnClick:BtnOut()
  self:CancelOpt()
  House:ExitDecorationMode()
end
function tbUi.tbOnClick:BtnSure()
  if not self.tbOptDecoration.bCanPut then
    me.CenterMsg("此处不能摆放")
    return
  end
  if self.tbOptDecoration.nId then
    RemoteServer.ChangeFurniturePos(self.tbOptDecoration.nId, self.tbOptDecoration.nX, self.tbOptDecoration.nY, self.tbOptDecoration.nRotation, self.tbOptDecoration.nSX, self.tbOptDecoration.nSY)
  else
    RemoteServer.PutFurniture(self.tbOptDecoration.nX, self.tbOptDecoration.nY, self.tbOptDecoration.nRotation, self.tbOptDecoration.nItemTId, self.tbOptDecoration.nSX, self.tbOptDecoration.nSY)
  end
  Ui.Effect.RemoveObjRepresent(self.tbOptDecoration.nRepId)
  self.pPanel:SetActive("PutSetting", false)
  self.tbOptDecoration = nil
  Decoration:ClearClientTempObs()
end
function tbUi.tbOnClick:BtnCannel()
  self:PackupFurniture()
end
function tbUi.tbOnClick:BtnRotate()
  if not self.tbOptDecoration then
    return
  end
  local nOldRotation = self.tbOptDecoration.nRotation or -1
  self.tbOptDecoration.nRotation = Decoration:GetNextRotation(self.tbOptDecoration.nTemplateId, self.tbOptDecoration.nRotation)
  if nOldRotation == self.tbOptDecoration.nRotation then
    me.CenterMsg("此家具不能旋转")
    return
  end
  self:ChangeObjPos(self.tbOptDecoration.nX, self.tbOptDecoration.nY, self.tbOptDecoration.nRotation)
end
function tbUi.tbOnClick:BtnEnlarge()
  if not self.tbOptDecoration then
    return
  end
  self:UpdateScalePanel(true)
end
function tbUi.tbOnClick:BtnOther()
  self.pPanel:SetActive("ScaleSetting", false)
  self.pPanel:SetActive("PutSetting", true)
end
