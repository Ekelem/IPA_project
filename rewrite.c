#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <stdint.h>

#define LARGEUR_ECRAN 1920
#define HAUTEUR_ECRAN 1080

double test = 0.0;
double SPEED_COEF = 20.0;
double Make = 20.0;

void init_ogl()
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(80, (double)LARGEUR_ECRAN/HAUTEUR_ECRAN, .1, 1000);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
    glEnable(GL_NORMALIZE);
    glClearColor(0, 0, 0, 0);

    glEnable(GL_LIGHT0);
    GLfloat ambient[]= {5,5,5,1};
    GLfloat diffuse[]= {1,3,3,5};
    glLightfv(GL_LIGHT0, GL_AMBIENT, ambient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, ambient);

    int MatSpec [4] = {1,1,1,1};
    glMaterialiv(GL_FRONT_AND_BACK,GL_SPECULAR,MatSpec);
    glMateriali(GL_FRONT_AND_BACK,GL_SHININESS,100);
    double hauteur_saut(int tpsms);
    //SDL_WarpMouseGlobal(LARGEUR_ECRAN/2, HAUTEUR_ECRAN/2);
    //SDL_SetRelativeMouseMode(SDL_TRUE);
}

void proceed()
{
    test = Make + (cos(SPEED_COEF));
}

void texture()
{
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 2, 2, 0, GL_RGB, GL_FLOAT, 0);
    glGenerateMipmap(GL_TEXTURE_2D);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, 0);
}

void update_look(double * ptr)  //rewritten
{
    *(ptr+3) = (*ptr) + cos(*(ptr+7))*cos(*(ptr+6));
    *(ptr+4) = *(ptr+1) + sin(*(ptr+7))*cos(*(ptr+6));
    *(ptr+5) = *(ptr+2) + sin(*(ptr+6));
}

void move_side(double * ptr)
{
    *(ptr) += sin(*(ptr + 7));
    *(ptr+1) += cos(*(ptr + 7));
}

void Debug_tool_decimal(uint32_t value)
{
    printf("decimal value :%d\n", value);
}

void Debug_tool_double(double value)
{
    printf("double value :%f\n", value);
}

void Debug_tool_float(float value)
{
    printf("double value :%f\n", value);
}