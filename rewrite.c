#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <stdint.h>

#define LARGEUR_ECRAN 1920
#define HAUTEUR_ECRAN 1080

/**
 * @brief      initialize Open GL
 */

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
    SDL_WarpMouseGlobal(LARGEUR_ECRAN/2, HAUTEUR_ECRAN/2);
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

/**
 * @brief      update camera look by angle (assembler version is not working)
 *
 * @param      ptr   The pointer
 */

void update_look(double * ptr)  //rewritten
{
    *(ptr+3) = (*ptr) + cos(*(ptr+7))*cos(*(ptr+6));
    *(ptr+4) = *(ptr+1) + sin(*(ptr+7))*cos(*(ptr+6));
    *(ptr+5) = *(ptr+2) + sin(*(ptr+6));
}

/**
 * @brief      print decimal value (called from assembler)
 *
 * @param[in]  value  The value
 */

void Debug_tool_decimal(uint32_t value)
{
    printf("decimal value :%d\n", value);
}

/**
 * @brief      print double value (called from assembler)
 *
 * @param[in]  value  The value
 */

void Debug_tool_double(double value)
{
    printf("double value :%f\n", value);
}

/**
 * @brief      print float value (called from assembler)
 *
 * @param[in]  value  The value
 */

void Debug_tool_float(float value)
{
    printf("double value :%f\n", value);
}
