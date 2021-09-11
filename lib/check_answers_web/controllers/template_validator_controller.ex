defmodule CheckAnswersWeb.TemplateValidatorController do
  use CheckAnswersWeb, :controller
  require Logger

  alias CheckAnswers.TemplateValidator

  @root_path Application.fetch_env!(:check_answers, :root_path)
  @questions_to_validate 6..180

  def validate(conn, _params) do
    render(conn, "validate.html", changeset: :check_answers)
  end

  def submit(conn, %{"answer_files" => answer_files, "template" => template_file}) do
    try do
      template_file_name = upload_file(template_file.path, template_file.filename)
      answer_file_names = Enum.map(answer_files, &upload_file(&1.path, &1.filename))

      validations =
        TemplateValidator.validate(
          answer_file_names,
          template_file_name,
          @questions_to_validate
        )

      delete_files(answer_file_names ++ [template_file_name])
      handle_validations(conn, validations)
    rescue
      error ->
      handle_error(conn, error)
    end
  end

  defp delete_files(files) do
    Enum.each(files, fn file -> File.rm("#{@root_path}#{file}") end)
  end

  defp upload_file(original_file_path, file_name) do
    new_file_name = "/tmp/#{timestamp}_#{file_name}"

    File.cp(original_file_path, "#{@root_path}#{new_file_name}")
    new_file_name
  end

  defp timestamp do
    :os.system_time(:milli_seconds)
  end

  defp handle_error(conn, error) do
    conn
    |> put_flash(:error, error.message)
    |> render("validate.html", changeset: :check_answers)
  end

  defp handle_validations(conn, validations) do
    invalid_answers = Enum.filter(validations, fn {validation, _} ->
      validation == :error
    end)

    if invalid_answers == [] do
      conn
      |> put_flash(:info, "Nenhuma Inconsistência!")
      |> render("result.html", results: invalid_answers)
    else
      render(conn, "result.html", results: invalid_answers)
    end
  end
end
