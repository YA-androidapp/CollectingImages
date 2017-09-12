#-*- coding:utf-8 -*-
# Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.

# pip install beautifulsoup4
# pip install chardet

import bs4
import chardet
import os
import sys
import urllib.request

# 宣言
dir_default = os.getcwd()

url_top = 'http://example.net/'
url_search = 'example.net/dummy'
url_replace_1 = 'example.net/dummy/img/'
url_replace_2 = 'example.net/src/img/'

max = 1000000

# page
i = 0
for i in range(0, max, 1):
    i = i + 1
    url_post = 'page-' + str(i)
    print(str(i) + '\t / \t' + str(max) +
          '\t: ' + url_post + '\t: ', end='')

    try:
        print('\t', end='')

        request = urllib.request.urlopen(url_top + url_post)
        html_post = request.read()
        guess = chardet.detect(html_post)
        html_post = html_post.decode(guess['encoding'])
        soup = bs4.BeautifulSoup(html_post)

        html_post_title = soup.title.string

        try:
            file_list_txt = open('list.txt', 'a')
            file_list_txt.write(url_post + '\t' + url_post +
                                '\t' + html_post_title + '\t\t')
            file_list_txt.close()
        except:
            pass

        html_post_links = soup.find_all('a', target='_blank')

        if(len(html_post_links) > 0):
            print(str(len(html_post_links)) + '\t: ', end='')

            os.mkdir('./' + url_post.replace('?', ''))
            os.chdir('./' + url_post.replace('?', ''))

            # an image
            for img_link in html_post_links:
                try:
                    if img_link.get('href').find(url_search) != -1:
                        print('.', end='')
                        img_img = img_link.get('href').replace(
                            url_replace_1, url_replace_2)
                        req = urllib.request.Request(img_img)
                        headers = {'Referer': img_link.get('href')}
                        req = urllib.request.Request(
                            img_img, headers=headers)
                        with urllib.request.urlopen(req) as response:
                            f = open(os.path.basename(img_img), 'wb')
                            f.write(response.read())
                except:
                    print(sys.exc_info())
    except:
        print(sys.exc_info())
    finally:
        os.chdir(dir_default)
