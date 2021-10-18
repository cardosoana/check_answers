defmodule CheckAnswers.TemplateValidator do
  alias CheckAnswers.FilesParser

  @not_found_message "NÃO ENCONTRADA"

  def validate(answer_files, template_file, questions_to_validate) do
    answers = FilesParser.answers_from_html(answer_files)
    template_answers = FilesParser.answers_from_csv(template_file)

    compare_answers(answers, template_answers, questions_to_validate)
  end

  defp compare_answers(answers, template_answers, questions_to_validate) do
    Enum.map(questions_to_validate, fn question_number ->
      answer = find_answer(answers, question_number) |> String.upcase()
      template_answer = find_answer(template_answers, question_number) |> String.upcase()

      question_answers = %{
        question: question_number,
        correct_answer: answer,
        template_answer: template_answer
      }

      if same_answer?(answer, template_answer) do
        {:ok, question_answers}
      else
        {:error, question_answers}
      end
    end)
  end

  defp same_answer?(answer, template_answer) do
    answer == template_answer && template_answer != @not_found_message
  end

  defp find_answer(answers, question_number) do
    case Enum.find(answers, &(&1.question == question_number)) do
      %{answer: answer} -> answer
      _ -> @not_found_message
    end
  end
end
