defmodule CheckAnswers.TemplateValidatorTest do
  use CheckAnswersWeb.ConnCase
  alias CheckAnswers.TemplateValidator

  describe "#validate" do
    test "returns list of answers validation" do
      answers_files = [
        "test/support/fixtures/responses01.html",
        "test/support/fixtures/responses02.html"
      ]

      template_file = "test/support/fixtures/template.csv"
      questions_to_validate = 6..10

      correct_answers = %{
        "6" => "A",
        "7" => "B",
        "8" => "C",
        "9" => "D",
        "10" => "E"
      }

      validations =
        TemplateValidator.validate(answers_files, template_file, questions_to_validate)

      Enum.each(questions_to_validate, fn question ->
        question_validation =
          Enum.find(validations, fn {_, question_answers} ->
            question_answers.question == question
          end)

        correct_answer = Map.get(correct_answers, "#{question}")

        assert question_validation ==
                 {:ok,
                  %{
                    question: question,
                    correct_answer: correct_answer,
                    template_answer: correct_answer
                  }}
      end)
    end
  end
end
