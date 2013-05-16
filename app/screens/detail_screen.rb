class DetailScreen < ProMotion::Screen

  attr_accessor :parentVC, :data, :date

  def will_appear

    @view_setup ||= begin

     @data.sort! { |a,b| a.sortableTime <=> b.sortableTime }


      self.setTitle("Details", subtitle:"for #{@date}")
      self.navigationController.navigationBar.barStyle = self.navigationController.toolbar.barStyle = UIBarStyleBlack
      self.navigationController.setToolbarHidden(false)

      #Create the labe at the bottom of the view.
      @label = set_attributes UILabel.alloc.initWithFrame(CGRectMake(0, 0, self.navigationController.toolbar.bounds.size.width, self.navigationController.toolbar.bounds.size.height)), {
        background_color: UIColor.clearColor,
        text_color: UIColor.whiteColor,
        text_alignment: UITextAlignmentCenter,
        line_break_mode: UILineBreakModeTailTruncation,
        font: UIFont.boldSystemFontOfSize(18),
        minimum_font_size: 10,
        autoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin,
        text: "#{incidentCount} Incidents & #{arrestCount} Arrests"
      }

      item = UIBarButtonItem.alloc.initWithCustomView(@label)
      self.toolbarItems = [item];

      # Done Button
      set_nav_bar_right_button "Done", action: :close_modal, type: UIBarButtonItemStyleDone

      @table = UITableView.alloc.initWithFrame(view.frame, style: UITableViewStylePlain)
      @table.dataSource = self
      @table.delegate = self

      self.view = @table
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(cell_identifier)
    if not cell
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:cell_identifier)
    end

    cell.imageView.image = UIImage.imageNamed( @data[indexPath.row].pinImage )
    cell.selectionStyle = UITableViewCellSelectionStyleBlue
    cell.textLabel.text = "#{@data[indexPath.row].title}"
    cell.detailTextLabel.text = "#{@data[indexPath.row].subtitle}"
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton

    return cell
  end

  def cell_identifier
    @@cell_identifier ||= 'Cell'
  end

  def tableView(tableView, numberOfRowsInSection: section)
    case section
    when 0
      @data.length
    else
      0
    end
  end

  # Tap on table Row
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tappedCrime( @data[indexPath.row] )
  end

  # Tap on row accessory
  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
    tappedCrime( @data[indexPath.row] )
  end


  def tappedCrime(marker)
    unless @parentVC.nil?
      @parentVC.closeDetailAndZoomToEvent(marker)
    end
  end

  def incidentCount
    incidents = @data.select { |crime| crime.type == "Incident" }
    incidents.length
  end

  def arrestCount
    arrests = @data.select { |crime| crime.type == "Arrest" }
    arrests.length
  end

  def close_modal
    self.navigationController.dismissModalViewControllerAnimated(true)
  end

end
