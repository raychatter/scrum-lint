require 'optparse'

module ScrumLint
  # `ScrumLint::Runner` is where it all begins. It sets up configuration, looks
  # up and validates the board, and then runs the lints
  class Runner

    include Callable

    LINTERS = {
      board: {
        [:current] => [
          Linter::ExtraList,
          Linter::ExtraDoneList,
          Linter::MissingTaskList,
        ],
        [:backlog] => [],
      },
      list: {
        [:task] => [],
        [:done] => [],
        [:project] => [],
      },
      card: {
        [:task] => [Linter::MissingHashTag],
        [:task, :active] => [Linter::MissingContext],
        [:task, :done] => [Linter::MissingExpendedPoints],
        [:project] => [],
      },
      repo: {
        [:active] => [],
      },
      issue: {
        [:open] => [Linter::StaleIssue],
      },
    }.freeze

    INTERACTIVE_LINTERS = {
      board: {},
      list: {},
      card: {
        [:task] => [
          InteractiveLinter::MissingHashTag,
          InteractiveLinter::MissingLabel,
        ],
      },
      repo: {},
      issue: {},
    }.freeze

    def call
      options = {}
      OptionParser.new do |opts|
        opts.banner = 'Usage: scrum-lint [options]'
        opts.on('-i', '--interactive', 'run in interactive mode') do
          options[:interactive] = true
        end
        opts.on('-h', '--help', 'prints this help') do
          puts opts
          exit
        end
      end.parse!

      ScrumLint::Configurator.()
      if options[:interactive]
        boards.each { |entity| run_interactive_linters(entity) }
      else
        boards.each { |entity| run_linters(entity) }
        repos.each { |repo| run_linters(repo) }
      end
    end

  private

    def repos
      ScrumLint::Octokit::Mapper.()
    end

    def run_interactive_linters(entity)
      fetch_linters(entity, linters: INTERACTIVE_LINTERS).each do |linter|
        linter.(entity)
      end

      entity.each do |item|
        run_interactive_linters(item)
      end
    end

    def run_linters(entity)
      fetch_linters(entity).each do |linter|
        linter.(entity)
      end

      entity.each do |item|
        run_linters(item)
      end
    end

    def fetch_linters(entity, linters: LINTERS)
      entity_linters = linters[entity.to_sym]
      keys_matching_tags = entity_linters.keys.select do |key|
        Set.new(entity.tags) >= Set.new(key)
      end
      entity_linters.values_at(*keys_matching_tags).flatten.uniq
    end

    def boards
      @boards ||= ScrumLint::Trello::Mapper.()
    end

  end
end
