------------------------------------------------------------------------------------------------------------------------
local A, L, V, P, G, N = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, AddonName
------------------------------------------------------------------------------------------------------------------------
local module = A:GetModule('deleteAucMail');

-- ==== Start
function module:Initialize() 
    self.Initialized = true
    self:RegisterEvent("MAIL_SHOW")
    -- self:RegisterEvent("MAIL_INBOX_UPDATE")
    -- "MAIL_INBOX_UPDATE"
end

function module:MAIL_SHOW()
    -- test

    -- test end
end

--     local count, mails, current = 1, 1, 1;
--     if count == nil then count = 1 end
--     mails = GetInboxNumItems()
--     -- if count > mails then count = 1 end
--     for ii=1, mails, 1 do
--     current = GetInboxInvoiceInfo(count)
--     if current == "seller_temp_invoice" then
--         GetInboxText(count);
--         DeleteInboxItem(count)
--     else
--         count = count + 1
--     end

-- function module:MAIL_INBOX_UPDATE() 
--     local count, mails, current = 1, 1, 1;
--     if count == nil then count = 1 end
--     mails = GetInboxNumItems()
--     if count > mails then count = 1 end
--     current = GetInboxInvoiceInfo(count)
--     if current == "seller_temp_invoice" then
--         GetInboxText(count);
--         DeleteInboxItem(count)
--     else
--         count = count + 1
--     end
-- end

-- ==== Callback & Register [last arg]
local function InitializeCallback()
	module:Initialize()
end
A:RegisterModule(module:GetName(), InitializeCallback)