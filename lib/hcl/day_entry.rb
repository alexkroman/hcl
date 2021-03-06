
class HCl 
  class DayEntry < TimesheetResource
    # Get the time sheet entries for a given day. If no date is provided
    # defaults to today.
    def self.all date = nil
      url = date.nil? ? 'daily' : "daily/#{date.strftime '%j/%Y'}"
      from_xml get(url)
    end

    def to_s
      "#{client} #{project} #{task} (#{hours})"
    end

    def self.from_xml xml
      doc = REXML::Document.new xml
      Task.cache_tasks doc
      doc.root.elements.collect('*/day_entry') do |day|
        new xml_to_hash(day)
      end
    end

    # Append a string to the notes for this task.
    def append_note new_notes
      # If I don't include hours it gets reset.
      # This doens't appear to be the case for task and project.
      DayEntry.post("daily/update/#{id}", <<-EOD)
      <request>
        <notes>#{notes << " #{new_notes}"}</notes>
        <hours>#{hours}</hours>
      </request>
      EOD
    end

    def self.with_timer
      all.detect {|t| t.running? }
    end

    def running?
      !@data[:timer_started_at].nil? && !@data[:timer_started_at].empty?
    end

    def initialize *args
      super
      # TODO cache client/project names and ids
    end

    def toggle
      DayEntry.get("daily/timer/#{id}")
      self
    end
  end
end
