defmodule CheckAnswersWeb.TemplateValidatorController do
  use CheckAnswersWeb, :controller
  require Logger

  alias CheckAnswers.TemplateValidator
  alias CheckAnswers.FilesHelper

  @questions_to_validate 6..180

  def validate(conn, _params) do
    render(conn, "validate.html", changeset: :check_answers)
  end

  def submit(conn, %{"answer_files" => answer_files, "template" => template_file}) do
    try do
      template_file_name = FilesHelper.upload_file(template_file.path, template_file.filename)
      answer_file_names = Enum.map(answer_files, &FilesHelper.upload_file(&1.path, &1.filename))

      validations =
        TemplateValidator.validate(
          answer_file_names,
          template_file_name,
          @questions_to_validate
        )

      FilesHelper.delete_files(answer_file_names ++ [template_file_name])
      handle_validations(conn, validations)
    rescue
      error ->
        handle_error(conn, error)
    end
  end

  defp handle_error(conn, error) do
    conn
    |> put_flash(:error, error.message)
    |> render("validate.html", changeset: :check_answers)
  end

  defp handle_validations(conn, validations) do
    invalid_answers =
      Enum.filter(validations, fn {validation, _} ->
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
