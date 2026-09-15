-- Modify runtimepath to also search the system-wide Vim directory
-- (eg. for Vim runtime files from Arch Linux packages)
vim.opt.runtimepath:append({ '/usr/share/vim/vimfiles', '/usr/share/vim/vimfiles/after' })
