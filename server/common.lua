ESX = {}
ESX.Jobs = {}
ESX.Players = {}
Core = {}
Core.UsableItemsCallbacks = {}
Core.ServerCallbacks = {}
Core.TimeoutCount = -1
Core.CancelledTimeouts = {}
Core.RegisteredCommands = {}

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

exports('getSharedObject', function()
	return ESX
end)

Core.LoadJobs = function()
	local Jobs = {}
	local file = load(LoadResourceFile('es_extended', '/data/jobs.lua'))()
	for job, data in pairs(file) do
        Jobs[job] = {name = job, label = data.name, grades = data.grade}
		for k, v in pairs(Jobs[job].grades) do
			Jobs[job].grades[tostring(k)] = v
		end
	end
	ESX.Jobs = Jobs
	print('[^2INFO^7] Loaded jobs data')
end

RegisterServerEvent('esx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[^2TRACE^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('esx:triggerServerCallback', function(name, requestId, ...)
	local source = source

	Core.TriggerServerCallback(name, requestId, source, function(...)
		TriggerClientEvent('esx:serverCallback', source, requestId, ...)
	end, ...)
end)

SetInterval(function()
	for _, xPlayer in pairs(ESX.Players) do
		local job     = xPlayer.job.grade_name
		local salary  = xPlayer.job.grade_salary
		if salary > 0 then
			if job == 'unemployed' then -- unemployed
				xPlayer.addAccountMoney('bank', salary)
				TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_help', salary), 'CHAR_BANK_MAZE', 9)
			elseif Config.EnableSocietyPayouts then -- possibly a society
				TriggerEvent('esx_society:getSociety', xPlayer.job.name, function (society)
					if society ~= nil then -- verified society
						TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
							if account.money >= salary then -- does the society money to pay its employees?
								xPlayer.addAccountMoney('bank', salary)
								account.removeMoney(salary)

								TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_MAZE', 9)
							else
								TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_MAZE', 1)
							end
						end)
					else -- not a society
						xPlayer.addAccountMoney('bank', salary)
						TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_MAZE', 9)
					end
				end)
			else -- generic job
				xPlayer.addAccountMoney('bank', salary)
				TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_MAZE', 9)
			end
		end
	end
end, Config.PaycheckInterval)

Core.LoadJobs()
print('[^2INFO^7] ESX ^5Legacy^0 initialized')
