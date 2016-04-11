module ScrumLint
  # `ScrumLint::Runner` is where it all begins. It sets up configuration, looks
  # up and validates the board, and then runs the lints
  class Runner

    include Callable

    LINTERS = {
      board: {
        current: [
          Linter::ExtraList,
          Linter::MissingTaskList,
          Linter::MissingContext,
        ],
        backlog: [],
      },
      list: { task: [], done: [], project: [] },
      card: { task: [], project: [] },
    }.freeze

    def call
      ScrumLint::Configurator.()
      boards.each do |board|
        run_linters(board)
      end
    end

  private

    def run_linters(entity)
      fetch_linters(entity).each do |linter|
        linter.(entity)
      end

      entity.each do |item|
        run_linters(item)
      end
    end

    def fetch_linters(entity)
      entity_linters = LINTERS[entity.to_sym]
      entity_linters.values_at(*entity.tags).flatten.uniq
    end

    def boards
      [board]
    end

    def board
      @board ||= ScrumLint::Board.new(locate_board)
    end

    def locate_board
      matching_boards = trello_boards.select do |board|
        board.name == board_name
      end
      raise 'multiple boards match' if matching_boards.size > 1
      matching_boards.first
    end

    def trello_boards
      Trello::Board.all
    end

    def board_name
      ScrumLint.config.board_name
    end

  end
end
