import json
from robot.api.deco import library, keyword
from owslib.csw import CatalogueServiceWeb as CSW
from owslib.fes import And, Or, PropertyIsEqualTo, PropertyIsGreaterThanOrEqualTo, PropertyIsLessThanOrEqualTo, PropertyIsLike, BBox, SortBy, SortProperty
from owslib.wms import WebMapService
import pyops

@library
class CatalogueServiceWeb:
    """Example helper to use the data and resources
    """
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '0.1'

    def __init__(self, base_url):
        """Initialise client session with provided base URL.
        """
        self.system_catalogue_endpoint = base_url
        self.csw = CSW(self.system_catalogue_endpoint, timeout=30)
        self.load_state()
    def load_state(self):
        """Load state from file 'state.json'.
        """
        self.state = {}
        try:
            with open("state.json") as state_file:
                self.state = json.loads(state_file.read())
                print(f"State loaded from file: {self.state}")
        except FileNotFoundError:
            pass
        except json.decoder.JSONDecodeError:
            print(f"ERROR loading state from file. Using clean state...")

    @keyword(name='Catalogue Save State')
    def save_state(self):
        """Save state to file 'state.json'.
        """
        state_filename = "state.json"
        with open(state_filename, "w") as state_file:
            state_file.write(json.dumps(self.state, sort_keys=True, indent=2))
            print("Client state saved to file:", state_filename)

    @keyword(name='Get Operations')
    def get_operations(self):
        """Return operations'.
        """
        return [op.name for op in self.csw.operations]
    
    @keyword(name='Get Constraints')
    def get_constraints(self, operation):
        """Return constraints'.
        """
        return self.csw.get_operation_by_name(operation).constraints
        

    @keyword(name='Get Results')
    def get_results(self, limit=None):
        """Return records'.
        """
        self.csw.getrecords2(maxrecords=limit)
        print(self.csw.results)
        return self.csw.results
    @keyword(name='Get Records')
    def get_records(self):
        """Return records'.
        """
        self.get_results(10)      
        for rec in self.csw.records:
            print(rec)
            print(self.csw.records[rec].references)
        return self.csw.records
    @keyword(name='Get Records Filtered')
    def get_records_filtered(self, sentinel_two=False):
        """Return records'.
        """
        if sentinel_two:
            filter_list = [PropertyIsEqualTo('apiso:ParentIdentifier', 'S2MSI1C')]
        else:
            bbox_query = BBox([37, 13.9, 37.9, 15.1])
            begin = PropertyIsGreaterThanOrEqualTo(propertyname='apiso:TempExtent_begin', literal='2021-04-02 00:00')
            end = PropertyIsLessThanOrEqualTo(propertyname='apiso:TempExtent_end', literal='2021-04-03 00:00')
            cloud = PropertyIsLessThanOrEqualTo(propertyname='apiso:CloudCover', literal='20')
            filter_list = [
                And(
                    [
                        bbox_query,  # bounding box
                        begin, end,  # start and end date
                        cloud        # cloud
                    ]
                )
            ]
        self.csw.getrecords2(constraints=filter_list, outputschema='http://www.isotc211.org/2005/gmd')
        for rec in self.csw.records:
            print(rec)
            print(f'identifier: {self.csw.records[rec].identifier}\ntype: {self.csw.records[rec].identification.identtype}\ntitle: {self.csw.records[rec].identification.title}\ndate: {self.csw.records[rec].datetimestamp}\n')
        return self.csw.records

    @keyword(name='Get Record Link')
    def get_record_link(self):
        self.get_records_filtered()
        selected_record = list(self.csw.records)[0]
        self.csw.getrecordbyid(id=[selected_record])
        links = self.csw.records[selected_record].references
        for link in links:
            scheme = link['scheme']
            if 'WMS' in scheme:
                wms_endpoint=link['url']
                print(wms_endpoint)
                return wms_endpoint

    @keyword(name='Get Map')
    def get_map(self, wms_endpoint):
        wms = WebMapService(wms_endpoint, version='1.3.0')
        return wms.contents

    @keyword(name='Check Array')
    def check_array(self, content, substring):
        for item in content:
            print(item)
            if substring not in item:
                return False
        return True

    @keyword(name='Get Record')
    def get_record_by_id(self, record_id):
        self.get_records_filtered(True)
        self.csw.getrecordbyid(id=[record_id])
        print(self.csw.records[record_id])
        return self.csw.records[record_id]

    @keyword(name='Reload Catalogue')
    def reload_csw(self, base_url):
        self.system_catalogue_endpoint = base_url
        self.csw = CSW(self.system_catalogue_endpoint, timeout=30)
        self.load_state()

    @keyword(name='Load Opensearch')
    def load_os(self, base_url):
        print(base_url)
        self.client = pyops.Client(description_xml_url=base_url)

    @keyword(name='Open Search')
    def search_os(self, params=None):
        return self.client.search(params)