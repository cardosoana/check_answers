defmodule CheckAnswers.TemplateValidator do
  require CSV

  @root_path Application.fetch_env!(:check_answers, :root_path)
  @answer_regex ~r/\d+.&#9;Resposta correta: [A-Z]/

  def validate(answer_files, template_file, questions_to_validate) do
    compare_answers(
      answers(answer_files),
      template_answers(template_file),
      questions_to_validate
    )
  end

  defp compare_answers(answers, template_answers, questions_to_validate) do
    Enum.map(questions_to_validate, fn question_number ->
      question_answer = find_answer(answers, question_number)
      template_answer = find_answer(template_answers, question_number)

      question_answers = %{
        question: question_number,
        correct_answer: question_answer,
        template_answer: template_answer
      }

      if question_answer == template_answer do
        {:ok, question_answers}
      else
        {:error, question_answers}
      end
    end)
  end

  defp answers(answer_files) do
    answer_files
    |> parse_html_to_string()
    |> scan_answers()
    |> Enum.map(&format_answer(&1))
  end

  defp template_answers(template_file) do
    template_file
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

  defp scan_answers(string) do
    Regex.scan(@answer_regex, string)
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

  defp find_answer(answers, question_number) do
    case Enum.find(answers, &(&1.question == question_number)) do
      %{answer: answer} -> answer
      _ -> "não encontrada"
    end
  end
end
