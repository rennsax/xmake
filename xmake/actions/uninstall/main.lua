--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2019, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        main.lua
--

-- imports
import("core.base.option")
import("core.base.task")
import("core.platform.platform")
import("core.base.privilege")
import("privilege.sudo")
import("uninstall")

-- main
function main()

    -- get the target name
    local targetname = option.get("target")

    -- config it first
    task.run("config", {target = targetname, require = "n"})

    -- attempt to uninstall directly
    try
    {
        function ()

            -- uninstall target
            uninstall(targetname)

            -- trace
            cprint("${bright}uninstall ok!${clear}${ok_hand}")
        end,

        catch
        {
            -- failed or not permission? request administrator permission and uninstall it again
            function (errors)

                -- try get privilege
                if privilege.get() then
                    local ok = try
                    {
                        function ()

                            -- uninstall target
                            uninstall(targetname)

                            -- trace
                            cprint("${bright}uninstall ok!${clear}${ok_hand}")

                            -- ok
                            return true
                        end
                    }

                    -- release privilege
                    privilege.store()

                    -- ok?
                    if ok then return end
                end

                -- show tips
                cprint("${bright color.error}error: ${clear}failed to uninstall, may permission denied!")

                -- continue to uninstall with administrator permission?
                if sudo.has() then

                    -- get confirm
                    local confirm = option.get("yes")
                    if confirm == nil then

                        -- show tips
                        cprint("${bright color.warning}note: ${clear}try continue to uninstall with administrator permission again?")
                        cprint("please input: y (y/n)")

                        -- get answer
                        io.flush()
                        local answer = io.read()
                        if answer == 'y' or answer == '' then
                            confirm = true
                        end
                    end

                    -- confirm to uninstall?
                    if confirm then

                        -- uninstall target with administrator permission
                        sudo.runl(path.join(os.scriptdir(), "uninstall_admin.lua"), {targetname or "__all", option.get("installdir"), option.get("prefix")})

                        -- trace
                        cprint("${bright}uninstall ok!${clear}${ok_hand}")
                    end
                end
            end
        }
    }
end
