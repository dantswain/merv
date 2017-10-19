defmodule Mix.Tasks.Merv.CopyStaticAssets do
  use Mix.Task

  @shortdoc "Copy merv static assets"
  def run(_args) do
    project_root = Path.expand("../../../../", __DIR__)
    ui_assets_path = Path.expand("merv_ui/priv/static", project_root)
    firmware_assets_path = Path.expand("merv_firmware/priv/static", project_root)
    IO.puts "Copying static assets from #{ui_assets_path} to #{firmware_assets_path}"
    File.mkdir_p(firmware_assets_path)
    File.cp_r!(ui_assets_path, firmware_assets_path)
  end
end
