from object_cython import Object
from character_cython import Enemy
from ui_cython import UI
import pygame

cdef class Create:
    cdef screen
    cdef player
    cdef list_obj
    cdef listEnemies
    cdef selected
    cdef selectors
    cdef listUIs
    cdef selectItems
    cdef selectedItems
    cdef list listofObjects

    def __init__(self, screen, object player, list list_obj):
        self.screen = screen
        self.player = player
        self.list_obj = list_obj #list of objects for map

        # retun this list
        self.listofObjects = [player] # listofObjects
        self.listEnemies = []

        self.selected = 0
        self.selectors = []
        self.listUIs = []

        #audios / sfx for selecting items
        self.selectItems = pygame.mixer.Sound('audio/select.wav')
        self.selectedItems = pygame.mixer.Sound('audio/selected.wav')
    
    def allobjs(self):
        return self.listofObjects

    def allenemies(self):
        return self.listEnemies

    def create(self):
        for obj in self.list_obj:
            object = Object(obj['rect'][0], obj['rect'][1], obj['rect'][2], obj['rect'][3], obj['type'], obj['name'])
            if obj['name'] in ['box_1']:
                object.loadChestBox(obj['items'])
            if obj['type'] == 'navigation':
                self.player.MapObjects[obj['distination']] = object
            self.listofObjects.append(object)
                    
    def draw(self):
        for obj in self.listofObjects:
            if obj != self.listofObjects[0]:
                obj.draw(self.screen)

    def pauseGame(self):
         cdef keys = pygame.key.get_just_pressed()

         if keys[pygame.K_ESCAPE]:
             self.selectItems.play()
             return True

    #  for UI
    def create_UI(self):
        for obj in self.list_obj:
            ui = UI(obj['rect'][0], obj['rect'][1], obj['rect'][2], obj['rect'][3], obj['name'], obj['type'])
            if ui._type == 'selector':
                ui.selected = obj['selected']
                self.selectors.append(ui)
            self.listUIs.append(ui)

    def draw_ui(self):
        for uis in self.listUIs:
            uis.draw(self.screen)
        # self.Select()

    def Select(self): # select from the main menu only
        cdef keys = pygame.key.get_just_pressed()

        if keys[pygame.K_TAB] or keys[pygame.K_DOWN]:
            self.selectItems.play()
            self.selected += 1
            if self.selected > (len(self.selectors) - 1):
                self.selected = 0

            for ui in self.selectors:
                ui.selected = 1
            self.selectors[self.selected].selected = 0

        elif keys[pygame.K_UP]:
            self.selectItems.play()
            self.selected -= 1
            if self.selected < 0:
                self.selected = (len(self.selectors) - 1)

            for ui in self.selectors:
                ui.selected = 1
            self.selectors[self.selected].selected = 0
        
        elif keys[pygame.K_SPACE]:
            self.selectedItems.play()
            return self.selected

    # for enemies
    def create_enemies(self):
        for enemy in self.list_obj:
            enmy = Enemy(enemy['rect'][0], enemy['rect'][1], enemy['rect'][2], enemy['rect'][3], enemy['name'])
            enmy.speed = float(enemy['speed'])
            enmy.defaultLife = int(enemy['default_life'])
            enmy.life = int(enemy['default_life'])
            self.listEnemies.append(enmy)

    def draw_enemy(self, objects):
        for enemy in self.listEnemies:
            if enemy.life <= 0:
                if not(enemy.push):
                    self.listEnemies.remove(enemy)
            enemy.draw(self.screen, objects)
            enemy.follow(self.player) # follow the player