=begin
Copyright (c) 2012 Mark Rickert

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
THE SOFTWARE.
=end

class DetailController < UIViewController

  def initWithData(data, date:date)
    @data = data
    @data.sort! { |a,b| a.sortableTime <=> b.sortableTime }
    @date = date
    self
  end

  def viewDidLoad

    self.setTitle("Details", subtitle:"for #{@date}")
    self.navigationController.navigationBar.barStyle = self.navigationController.toolbar.barStyle = UIBarStyleBlack
    self.navigationController.setToolbarHidden(false)

    
    #Create the labe at the bottom of the view.
    @label = UILabel.alloc.initWithFrame(CGRectMake(0, 0, self.navigationController.toolbar.bounds.size.width, self.navigationController.toolbar.bounds.size.height))
    @label.backgroundColor = UIColor.clearColor
    @label.textColor = UIColor.whiteColor
    @label.textAlignment = UITextAlignmentCenter
    @label.lineBreakMode = UILineBreakModeTailTruncation
    @label.font = UIFont.boldSystemFontOfSize 18
    @label.minimumFontSize = 10
    @label.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
                                 UIViewAutoresizingFlexibleLeftMargin | 
                                 UIViewAutoresizingFlexibleRightMargin

    item = UIBarButtonItem.alloc.initWithCustomView(@label)
    self.toolbarItems = [item];

    backButton = UIBarButtonItem.alloc.initWithTitle(
      "Done", 
      style:UIBarButtonItemStyleDone, 
      target:self, 
      action:"closeModal")
    self.navigationItem.rightBarButtonItem = backButton;

    @table = UITableView.alloc.initWithFrame(view.frame, style: UITableViewStylePlain)
    @table.dataSource = self
    @table.delegate = self

    self.view = @table

    # Set the number of incidents and arrests
    @label.text = "#{incidentCount} Incidents & #{arrestCount} Arrests";

  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(cell_identifier)
    if not cell
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:cell_identifier)
    end

    cell.imageView.image = UIImage.imageNamed( @data[indexPath.row].pinImage )
    cell.selectionStyle = UITableViewCellSelectionStyleNone
    cell.textLabel.text = "#{@data[indexPath.row].title}"
    cell.detailTextLabel.text = "#{@data[indexPath.row].subtitle}"

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
  
  def closeModal
    self.navigationController.dismissModalViewControllerAnimated(true)
  end

  def incidentCount
    incidents = @data.select { |crime| crime.type == "Incident" }
    incidents.length
  end

  def arrestCount
    arrests = @data.select { |crime| crime.type == "Arrest" }
    arrests.length
  end

end