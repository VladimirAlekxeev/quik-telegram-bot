
package.cpath=package.cpath..";.\\?.dll;.\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\?.dll;C:\\Program Files (x86)\\Lua\\5.1\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\?.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\loadall.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\loadall.dll;C:\\Program Files\\Lua\\5.1\\?.dll;C:\\Program Files\\Lua\\5.1\\?51.dll;C:\\Program Files\\Lua\\5.1\\clibs\\?.dll;C:\\Program Files\\Lua\\5.1\\clibs\\?51.dll;C:\\Program Files\\Lua\\5.1\\loadall.dll;C:\\Program Files\\Lua\\5.1\\clibs\\loadall.dll"
package.path=package.path..";.\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?\\init.lua;C:\\Program Files (x86)\\Lua\\5.1\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\?\\init.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.luac;C:\\Program Files\\Lua\\5.1\\lua\\?.lua;C:\\Program Files\\Lua\\5.1\\lua\\?\\init.lua;C:\\Program Files\\Lua\\5.1\\?.lua;C:\\Program Files\\Lua\\5.1\\?\\init.lua;C:\\Program Files\\Lua\\5.1\\lua\\?.luac;"

local is_run = true

--
local update_id = 0

--В файле telegram_settings.lua должны быть инициализированы переменные token и from_id
require ("telegram_settings")

-- Инициализируем бота
local bot = require("lua-bot-api").configure(token)

local my_orders = {} -- список обработанных ордеров для контроля, что уже отправляли по нему инфо в телеграм
local my_trades = {} -- список обработанных сделок для контроля


function main()
    while is_run do

        sleep(1000)
        update_id = telegram_get (update_id)

    end;
end

function OnInit()
	message("Telegram-bot started!",1)
end

function OnStop()
    is_run = false
    message("Telegram-bot stopped!",1)
end

function OnOrder(order)

	if orders_info ~= true then return end -- молчим о заявках, если нужно

	if check_order (order.order_num) == 0 then

		if bit.band(order.flags,1)>0 then

		 	if bit.band(order.flags,4)>0 then
				order_direction = "ORDER_SELL"
		 	else
				order_direction = "ORDER_BUY"
		 	end

			bot.sendMessage(from_id, order_direction.." "..order.sec_code.." P="..order.price.." Q="..order.balance.." #"..order.order_num)

		else
			--если заявка не активна
			if bit.band(order["flags"],1)>0 then

				if bit.band(order["flags"],8)>0 then
					return
				else
					return
				end

			end
		end
	end
end

function OnTrade(trade_data)

	if trades_info ~= true then return end -- молчим о сделках, если нужно

	if check_trade(trade_data.trade_num) == 0 then

		local trade_dir

		if bit.band(trade_data.flags,4) > 0 then
			trade_dir = "TRADE_SELL #"
		else
			trade_dir = "TRADE_BUY #"
		end

		bot.sendMessage(from_id, trade_dir..trade_data.trade_num.." "..trade_data.sec_code.." P="..trade_data.price.." Q="..trade_data.qty)

	end
end

function check_order(ord_num)
	--проверяет приходила уже инфо по ордеру с номером ord_num или нет.
	--если приходила возвращает 1, если не приходила возвращает 0, и добавляет номер в список обработанных
	for i = 1, #my_orders, 1 do
		if ord_num == my_orders[i] then
			return 1
		end
	end

	table.insert(my_orders,ord_num) -- добавляем номер ордела в список обработанных
	return 0
end

function check_trade(trade_num)
	--проверяет приходила уже инфо по сделке с номером trade_num или нет.
	--если приходила возвращает 1, если не приходила возвращает 0, и добавляет номер в список обработанных
	for i = 1, #my_trades, 1 do
		if trade_num == my_trades[i] then
			return 1
		end
	end

	table.insert(my_trades,trade_num) -- добавляем номер сделки в список обработанных
	return 0
end


function telegram_get(update_id)

        local updates = bot.getUpdates(update_id)


		-- for each update, check the message
		-- Note: processing a message does not prevent it from appearing again, unless
		-- you feed it's update id (incremented by one) back into getUpdates()
		for key, query in pairs(updates.result) do

		 	update_id = query.update_id
        	--message (tostring(update_id),1)

		  -- only reply to private chats, not groups
			if(query.message.chat.type == "private") then

				message(query.message.from.id.." >> "..update_id.." >> "..query.message.text,1)

			    -- if message text was 'ping'
			    if query.message.text == "Ping" then
			     -- reply with 'pong'
			    	bot.sendMessage(query.message.from.id, "Pong >> "..tostring(update_id))
			    -- if message text was 'photo'
			    --elseif query.message.text == "photo" then
			    -- get the users profile pictures
			    --local profilePicture = getUserProfilePhotos(query.message.from.id)
			    -- and send the first one back to him using its file id
			    --sendPhoto(query.message.from.id, profilePicture.result.photos[1][1].file_id)

			    elseif query.message.text == "Ri" then

			    	if tonumber(getParamEx("SPBFUT","RIM6","STATUS").param_value) == 1 then status = "Торгуется" else status = "Не торгуется" end
			    	bot.sendMessage(query.message.from.id, "RIM6 BID >> "..tostring(getParamEx("SPBFUT","RIM6","BID").param_value).." >> "..status)

				elseif query.message.text == "Usd" then

			    	if tonumber(getParamEx("CETS","USD000UTSTOM","STATUS").param_value) == 1 then status = "Торгуется" else status = "Не торгуется" end
			    	bot.sendMessage(query.message.from.id, "USD BID >> "..tostring(getParamEx("CETS","USD000UTSTOM","BID").param_value).." >> "..status)

--				elseif query.message.text == "Fut" then
--
--					Fut = getFuturesLimit("SPBFUT", "410097К", 0).varmargin
--			     	bot.sendMessage(query.message.from.id, tostring(Fut).." fut USD BID >> "..tostring(getParamEx("CETS","USD000UTSTOM","BID").param_value))

			    else

			    	if isConnected()==1 then status = "Is Connected" else status = "Not Connected" end
			    	bot.sendMessage(query.message.from.id, query.message.text .." >> ".. status)

			    end

		  	end
		end

		return update_id+1
end
