
local script = {}

local projectMountName = "project"

function script.folderDropped(self, absPath)
	if self.projectPath then
		love.filesystem.unmount(self.projectPath)
	end
	self.projectPath = absPath
	love.filesystem.mount(self.projectPath, projectMountName)

	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
	filesPanel:call("setFolder", projectMountName)
end

return script
