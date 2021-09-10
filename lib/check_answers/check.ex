defmodule CheckAnswers.CheckAnswers do
  require CSV

  @question_answer_regex ~r/\d+.&#9;Resposta correta: [A-Z]/

  def check(answer_files, template_file, questions_to_check) do
    # require IEx; IEx.pry
    file_question_answers =
      answer_files
      |> parse_html_files_to_string()
      |> extract_question_answers()
      |> Enum.map(fn question_answer ->
        question_answer_from_file_to_map(question_answer)
      end)

    template_question_answers =
      template_file
      |> parse_csv_file()
      |> Enum.map(fn {:ok, csv_row} ->
        question_answer_from_csv_to_map(csv_row)
      end)

    Enum.map(questions_to_check, fn question_number ->
      answer_file_answer =
        file_question_answers
        |> Enum.find(&(&1.question == question_number))
        |> Map.get(:answer)

      template_answer =
        template_question_answers
        |> Enum.find(&(&1.question == question_number))
        |> Map.get(:answer)

      if answer_file_answer == template_answer do
        "Questão #{question_number}: OK"
      else
        "Questão #{question_number}: INCORRETA"
      end
    end)
  end

  defp question_answer_from_file_to_map(string) do
    [question, answer] =
      string
      |> Enum.at(0)
      |> String.split(".&#9;Resposta correta: ")

    {question_int, _} = Integer.parse(question)
    %{question: question_int, answer: answer}
  end

  defp question_answer_from_csv_to_map(csv_row) do
    [_, _, _, _, question, answer] =
      csv_row
      |> Enum.at(0)
      |> String.split(";")

    {question_int, _} = Integer.parse(question)
    %{question: question_int, answer: answer}
  end
  

  defp extract_question_answers(string) do
    Regex.scan(@question_answer_regex, string)
  end

  defp parse_csv_file(file) do
    file
    |> Path.expand(File.cwd!())
    |> File.stream!()
    |> CSV.decode()
    |> Enum.map(& &1)
    |> Enum.drop(1)
  end

  defp parse_html_files_to_string(files) do
    {_, all_text} =
      Enum.map_reduce(files, "", fn file, all_text ->
        {:ok, file_text} =
          file
          |> Path.expand(File.cwd!())
          |> File.read()

        {file_text, all_text <> file_text}
      end)

    all_text
  end
end
