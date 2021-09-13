defmodule CheckAnswers.FilesHelper do
  @root_path Application.fetch_env!(:check_answers, :root_path)

  def delete_files(files) do
    Enum.each(files, fn file -> File.rm("#{@root_path}#{file}") end)
  end

  def upload_file(original_file_path, file_name) do
    new_file_name = "/tmp/#{timestamp}_#{file_name}"

    File.cp(original_file_path, "#{@root_path}#{new_file_name}")
    new_file_name
  end

  defp timestamp do
    :os.system_time(:milli_seconds)
  end
end
