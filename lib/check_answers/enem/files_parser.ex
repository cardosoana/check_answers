defmodule CheckAnswers.FilesParser do
  require CSV

  @root_path Application.fetch_env!(:check_answers, :root_path)
  @answer_regex ~r/\d+.&#9;Resposta correta: [A-Z]/

  def answers_from_html(files) do
    files
    |> parse_html_to_string()
    |> scan_answers()
    |> Enum.map(&format_answer(&1))
  end

  def answers_from_csv(file) do
    file
    |> parse_csv()
    |> Enum.map(&format_template_answer(&1))
  end

  defp format_answer(string) do
    [question, answer] =
      string
      |> Enum.at(0)
      |> String.split(".&#9;Resposta correta: ")

    {question_int, _} = Integer.parse(question)
    %{question: question_int, answer: answer}
  end

  defp format_template_answer({:ok, [csv_row | _]}) do
    case String.split(csv_row, ";") do
      [_, _, _, _, question, answer] ->
        {question_int, _} = Integer.parse(question)
        %{question: question_int, answer: answer}

      _ ->
        raise "CSV com formato incorreto!"
    end
  end

  defp parse_csv(file) do
    "#{@root_path}#{file}"
    |> File.stream!()
    |> CSV.decode()
    |> Enum.map(& &1)
    |> Enum.drop(1)
  end

  defp parse_html_to_string(files) do
    files
    |> Enum.map(&File.read!("#{@root_path}#{&1}"))
    |> Enum.join()
  end

  defp scan_answers(string) do
    Regex.scan(@answer_regex, string)
  end
end
