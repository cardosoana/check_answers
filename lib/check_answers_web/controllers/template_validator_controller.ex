defmodule CheckAnswersWeb.TemplateValidatorController do
  use CheckAnswersWeb, :controller

  def validate(conn, _params) do
    render(conn, "validate.html", changeset: :check_answers)
  end

  def submit(conn, %{"answer_files" => answer_files, "template" => template_file} = params) do
    template_file_name =
      if template_file do
        upload_file(template_file.path, template_file.filename)
      end

    answer_file_names =
      if answer_files do
        Enum.map(answer_files, fn answer_file ->
          upload_file(answer_file.path, answer_file.filename)
        end)
      end

    results =
      CheckAnswers.TemplateValidator.validate(answer_file_names, template_file_name, 6..180)

    delete_files(answer_file_names ++ [template_file_name])

    render(conn, "result.html", results: results)
  end

  defp delete_files(files) do
    Enum.each(files, fn file -> File.rm("#{File.cwd!()}/#{file}") end)
  end

  defp upload_file(original_file_path, file_name) do
    new_file_name = "tmp/#{timestamp}_#{file_name}"
    File.cp(original_file_path, "#{File.cwd!()}/#{new_file_name}")
    new_file_name
  end

  defp timestamp do
    :os.system_time(:milli_seconds)
  end
end
