if Config.Core.DebugMode then
    CreateThread(function()
        Wait(5000) -- Wait for resources to load
        
        -- Check if cm-images is running
        if GetResourceState('cm-images') ~= 'started' then
            CMCore.Logger.Warn('Images', 'cm-images resource is not started! Images will not load.')
            return
        end
        
        CMCore.Logger.Success('Images', 'cm-images resource detected')
        
        -- You could add more validation here
        -- Like checking if specific images exist
    end)
end