__author__ = 'quang'
import urllib2,re,json
if __name__ == '__main__':
    medianAge = "median\s\w+\s\w+\s\d+"
    pattern = re.compile(medianAge)

    url = "https://en.wikipedia.org/w/api.php?action=query&titles=Pittsburgh&prop=revisions&rvprop=content&format=json"
    link = urllib2.urlopen(url)
    page = link.read()
    json_obj = json.loads(page)
    result_pages = json_obj.get('query').get('pages')
    for item in result_pages:
        result = result_pages.get(item).get('revisions')[0].get('*').encode('ascii','replace')

    newresult = result
    strMedianAge = re.sub(r'/\w+\s\w+\s\w+\s/', '',re.findall(medianAge,newresult))
    pass
    pass

