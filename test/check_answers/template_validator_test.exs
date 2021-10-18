defmodule CheckAnswers.TemplateValidatorTest do
  use CheckAnswersWeb.ConnCase
  alias CheckAnswers.TemplateValidator

  @answer_files [
    "/test/support/fixtures/responses01.html",
    "/test/support/fixtures/responses02.html"
  ]

  @template_file "/test/support/fixtures/template.csv"
  @lowercase_template_file "/test/support/fixtures/template_lowercase.csv"
  @wrong_template_file "/test/support/fixtures/wrong_template.csv"
  @missing_questions_template_file "/test/support/fixtures/missing_questions_template.csv"
  @wrong_format_template_file "/test/support/fixtures/wrong_format_template.csv"

  @questions_to_validate 6..10
  @correct_answers %{
    "6" => "A",
    "7" => "B",
    "8" => "C",
    "9" => "D",
    "10" => "E"
  }

  describe "#validate" do
    test "returns :ok when template answer is correct" do
      validations =
        TemplateValidator.validate(
          @answer_files,
          @template_file,
          @questions_to_validate
        )

      assert Enum.count(validations) == Enum.count(@questions_to_validate)

      Enum.each(validations, fn {validation, question_answers} ->
        correct_answer = Map.get(@correct_answers, "#{question_answers.question}")

        assert :ok = validation

        assert %{
                 correct_answer: correct_answer,
                 template_answer: correct_answer
               } = question_answers
      end)
    end

    test "returns :ok when template lowercase answer is correct" do
      validations =
        TemplateValidator.validate(
          @answer_files,
          @lowercase_template_file,
          @questions_to_validate
        )

      assert Enum.count(validations) == Enum.count(@questions_to_validate)

      Enum.each(validations, fn {validation, question_answers} ->
        correct_answer = Map.get(@correct_answers, "#{question_answers.question}")

        assert :ok = validation

        assert %{
                 correct_answer: correct_answer,
                 template_answer: correct_answer
               } = question_answers
      end)
    end

    test "returns :error when template answer is incorrect" do
      validations =
        TemplateValidator.validate(
          @answer_files,
          @wrong_template_file,
          @questions_to_validate
        )

      assert {:error, question_answers} = Enum.at(validations, 1)
      assert question_answers.correct_answer == "B"
      assert question_answers.template_answer == "C"

      assert {:error, question_answers} = Enum.at(validations, 2)
      assert question_answers.correct_answer == "C"
      assert question_answers.template_answer == "B"
    end

    test "returns :error when template does not contain the answer" do
      validations =
        TemplateValidator.validate(
          @answer_files,
          @missing_questions_template_file,
          @questions_to_validate
        )

      assert {:error, question_answers} = Enum.at(validations, 3)
      assert question_answers.correct_answer == "D"
      assert question_answers.template_answer == "NÃO ENCONTRADA"

      assert {:error, question_answers} = Enum.at(validations, 4)
      assert question_answers.correct_answer == "E"
      assert question_answers.template_answer == "NÃO ENCONTRADA"
    end

    test "returns :error when answer files do not contain the answer" do
      validations =
        TemplateValidator.validate(
          ["/test/support/fixtures/responses01.html"],
          @template_file,
          @questions_to_validate
        )

      assert {:error, question_answers} = Enum.at(validations, 3)
      assert question_answers.correct_answer == "NÃO ENCONTRADA"
      assert question_answers.template_answer == "D"

      assert {:error, question_answers} = Enum.at(validations, 4)
      assert question_answers.correct_answer == "NÃO ENCONTRADA"
      assert question_answers.template_answer == "E"
    end

    test "returns :error when template and answer files do not contain the answer" do
      validations =
        TemplateValidator.validate(
          ["/test/support/fixtures/responses01.html"],
          @missing_questions_template_file,
          @questions_to_validate
        )

      assert {:error, question_answers} = Enum.at(validations, 3)
      assert question_answers.correct_answer == "NÃO ENCONTRADA"
      assert question_answers.template_answer == "NÃO ENCONTRADA"

      assert {:error, question_answers} = Enum.at(validations, 4)
      assert question_answers.correct_answer == "NÃO ENCONTRADA"
      assert question_answers.template_answer == "NÃO ENCONTRADA"
    end

    test "raises error when template format is wrong" do
      assert_raise RuntimeError, "CSV com formato incorreto!", fn ->
        TemplateValidator.validate(
          @answer_files,
          @wrong_format_template_file,
          @questions_to_validate
        )
      end
    end
  end
end
