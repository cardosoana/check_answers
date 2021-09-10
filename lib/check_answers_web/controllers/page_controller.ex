defmodule CheckAnswersWeb.PageController do
  use CheckAnswersWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", changeset: :check_answers)
  end

  def check(conn, %{"answer_files" => answer_files, "template" => template_file} = params) do 
    template_file_name = if template_file do
      upload_file(template_file.path, template_file.filename)
    end

    answer_file_names = if answer_files do
      Enum.map(answer_files, fn answer_file -> 
        upload_file(answer_file.path, answer_file.filename)
      end)
    end

    results = CheckAnswers.CheckAnswers.check(answer_file_names, template_file_name, 6..90)
    
    render(conn, "result.html", results: results)
  end


  defp upload_file(original_file_path, file_name) do
    new_file_name = "tmp/#{timestamp}_#{file_name}"
    File.cp(original_file_path, "#{File.cwd!}/#{new_file_name}")
    new_file_name
  end

  defp timestamp do
    :os.system_time(:milli_seconds)
  end
end
