local addonName,G = ... ;

---[[註解]]
SpellUtil = _G[SpellUtil] or {
	const_min = 1,
	const_max = 999999,
	min_id = 1,
	max_id = 999999,
	SpellPool = {},
	SpellIDGroupByName = {},
}
--[[----------------------------------------------------------------------
function SpellUtil:New(obj)
New方法用來讓新的物件可以繼承這個類別所有方法及屬性
利用 setmetatable(新物件, 類別物件) 及 
類別物件.__index = 類別物件 的指令來作到模擬繼承
-------------------------------------------------------------------------]]
function SpellUtil:New(objInstance)
	objInstance = objInstance or {}
	setmetatable(objInstance, self)
	self.__index = self
	return objInstance
end
--[[----------------------------------------------------------------------
function SpellUtil:New(objInstance)
釋放instance 物件
-------------------------------------------------------------------------]]
function SpellUtil:Release(objInstance)
	self:dump(SpellUtil)
	self:dump(self)
	self:dump(objInstance)
end
--[[----------------------------------------------------------------------
SpellUtil:SetMinID(id)
-------------------------------------------------------------------------]]
function SpellUtil:SetMinID(id)	
	
	if (id == nil) or (id < self.const_min) then 
		id = self.const_min 
	end

	self.min_id = id

	return self.min_id

end
--[[----------------------------------------------------------------------
SpellUtil:GetMinID()

-------------------------------------------------------------------------]]
function SpellUtil:GetMinID()
	if self.min_id then
		return self.min_id
	end
end

--[[----------------------------------------------------------------------
SpellUtil:SetMaxID(id)
-------------------------------------------------------------------------]]
function SpellUtil:SetMaxID(id)	
	if (id == nil) or (id > self.const_max) then 
		id = self.const_max 
	end
	
	self.max_id = id
	
	return self.max_id

end

--[[----------------------------------------------------------------------
SpellUtil:GetMaxID()
-------------------------------------------------------------------------]]
function SpellUtil:GetMaxID()
	if self.max_id then
		return self.max_id
	end
end

--[[----------------------------------------------------------------------
SpellUtil:CreateSpellPool()
建立並傳回所有法術資訊表格
P.S.由於較為耗時,建議在PLAYER_ENTER_WORLD事件跑過一次後
之後以SpellUtil:GetSpellPool()查詢即可
-------------------------------------------------------------------------]]
function SpellUtil:CreateSpellPool() 		
	for id = self.min_id, self.max_id do
		self.SpellPool[id] = {GetSpellInfo(id)}	
	end
	return self.SpellPool
end

--[[----------------------------------------------------------------------
SpellUtil:GetSpellPool()
傳回所有法術資訊表格
P.S 必須曾經執行過SpellUtil:CreateSpellPool() 	
-------------------------------------------------------------------------]]
function SpellUtil:GetSpellPool()
	return self.SpellPool
end

--[[----------------------------------------------------------------------
SpellUtil:GetSpellNameByID(id)
依照傳入的法術ID,回傳法術名稱
-------------------------------------------------------------------------]]
function SpellUtil:GetSpellNameByID(id)
	local pool = self:GetSpellPool()
	local const_SpellNameIndex = 1
	if #{pool} > 0 then	
		local name = pool[id][const_SpellNameIndex]
		if name then 
			return pool[id][const_SpellNameIndex] 		
		end
	end
end

--[[----------------------------------------------------------------------
SpellUtil:GetSpellIDGroupByName(keyname)
依照傳入的法術名稱關鍵字找尋符合或部份符合的法術名稱,並傳回法術id,
因為可能回傳一個以上,所以一律以表格形式傳回.
P.S.為了效率,會先在快取表格做搜尋(索引數較低,命中高,耗時較低),
若無才從全部的法術id資訊池進行搜尋並複製至快取池((索引數較高,命中低,耗時較高))
-------------------------------------------------------------------------]]
function SpellUtil:GetSpellIDGroupByName(keyname)		
	for id = self.min_id, self.max_id do
		
		if not(self.SpellIDGroupByName[keyname]) then 
			self.SpellIDGroupByName[keyname] = self.SpellIDGroupByName[keyname] or {}
		end

		if not(self.SpellIDGroupByName[keyname][id]) then
			local SpellName = self:GetSpellNameByID(id) 
			if SpellName and strfind(SpellName,keyname) then 				
				self.SpellIDGroupByName[keyname][id] = GetSpellLink(id)
			end
		end
	end
	
	return self.SpellIDGroupByName[keyname]
end

--[[----------------------------------------------------------------------
SpellUtil:dump(tbl)
印出表格內所有元素,包含其下所有表格內容
-------------------------------------------------------------------------]]
function SpellUtil:dump(tbl)
	if tbl then
		for k,v in pairs(tbl) do 
			if v and (type(v) == "table") then 
				self:dump(v)
			else
				print(k,v)
			end
		end	
	end
end
