/* Ver archivo LICENSE para detalles de copyright y licencia. */

#include <X11/XF86keysym.h>

/* Apariencia */
static const unsigned int borderpx  = 2;        /* píxeles del borde de las ventanas */
static const unsigned int snap      = 32;       /* píxeles de ajuste */
static const unsigned int gappih    = 10;       /* espacio interior horizontal entre ventanas */
static const unsigned int gappiv    = 10;       /* espacio interior vertical entre ventanas */
static const unsigned int gappoh    = 10;       /* espacio exterior horizontal entre ventanas y borde de pantalla */
static const unsigned int gappov    = 10;       /* espacio exterior vertical entre ventanas y borde de pantalla */
static const int smartgaps          = 0;        /* 1 significa sin espacio exterior cuando solo hay una ventana */
static const unsigned int systraypinning = 0;   /* 0: systray sigue al monitor seleccionado, >0: fijar systray al monitor X */
static const unsigned int systrayspacing = 2;   /* espaciado del systray */
static const int systraypinningfailfirst = 1;   /* 1: si falla el pinning, mostrar systray en 1er monitor, 0: en último monitor */
static const int showsystray        = 1;        /* 0 significa no mostrar systray */
static const int showbar            = 1;        /* 0 significa no mostrar barra */
static const int showtab            = showtab_auto;
static const int toptab             = 1;        /* 0 significa pestañas abajo */
static const int floatbar           = 1;        /* 1: barra flotante (sin relleno), 0: barra con relleno */
static const int topbar             = 1;        /* 0 significa barra abajo */
static const int horizpadbar        = 5;        /* relleno horizontal de la barra */
static const int vertpadbar         = 11;       /* relleno vertical de la barra */
static const int vertpadtab         = 35;       /* relleno vertical de pestañas */
static const int horizpadtabi       = 15;       /* relleno horizontal interior de pestañas */
static const int horizpadtabo       = 15;       /* relleno horizontal exterior de pestañas */
static const int scalepreview       = 4;        /* escala de vista previa */
static const int tag_preview        = 0;        /* 1: habilitar vista previa de etiquetas, 0: desactivado */
static const int colorfultag        = 1;        /* 0: usar SchemeSel para etiquetas seleccionadas no vacías */

/* Comandos para control de volumen y brillo */
static const char *upvol[]   = { "/usr/bin/pactl", "set-sink-volume", "0", "+5%",     NULL };
static const char *downvol[] = { "/usr/bin/pactl", "set-sink-volume", "0", "-5%",     NULL };
static const char *mutevol[] = { "/usr/bin/pactl", "set-sink-mute",   "0", "toggle",  NULL };
static const char *light_up[] = {"/usr/bin/light", "-A", "5", NULL};
static const char *light_down[] = {"/usr/bin/light", "-U", "5", NULL};

static const int new_window_attach_on_end = 0; /* 1: nueva ventana al final, 0: nueva ventana al frente (por defecto) */

#define ICONSIZE 10   /* tamaño de iconos */
#define ICONSPACING 8 /* espacio entre icono y título */


static const char *termcmd[]  = { "alacritty", "--working-directory", "/home/g3k", NULL };


/* Fuentes */
static const char *fonts[] = { "xos4 Terminus:style:medium:size=20", "Iosevka:style:medium:size=19"};

// Tema
#include "themes/rusia.h"

/* Esquemas de colores */
static const char *colors[][3] = {
    /* fg         bg         border   */
    [SchemeNorm] = { gray3,    black,     gray2 },      // Normal: gris oscuro sobre negro
    [SchemeSel]  = { gray4,    red,       red   },      // Seleccionado: gris claro sobre rojo (antes blue)
    [SchemeTitle]  = { white,    black,     black },    // Título activo: blanco sobre negro
    [TabSel]     = { red,      gray2,     black },      // Pestaña seleccionada: rojo sobre gris oscuro
    [TabNorm]    = { gray3,    black,     black },      // Pestaña normal: gris oscuro sobre negro
    [SchemeTag]  = { gray3,    black,     black },      // Etiqueta normal: gris oscuro
    [SchemeTag1] = { red,      black,     black },      // Etiqueta 1: rojo puro
    [SchemeTag2] = { red,     black,     black },      // Etiqueta 2: rojo anaranjado
    [SchemeTag3] = { red,black,     black },      // Etiqueta 3: rojo parduzco 
    [SchemeTag4] = { red, black,     black },      // Etiqueta 4: rojo oscuro
    [SchemeTag5] = { red,     black,     black },      // Etiqueta 5: rosa rojizo
    [SchemeLayout] = { dark_red,black,     black },     // Layout: rojo oscuro 
    [SchemeBtnPrev] = { dark_red,black,   black },      // Botón Prev: rojo oscuro
    [SchemeBtnNext] = { red_yellow,black, black },      // Botón Next: rojo amarillento
    [SchemeBtnClose] = { red,    black,     black },    // Botón Close: rojo puro
};

/* Etiquetas */
static char *tags[] = {"", "", "", "", ""};

/* Esquemas de colores para etiquetas */
static const int tagschemes[] = {
    SchemeTag1, SchemeTag2, SchemeTag3, SchemeTag4, SchemeTag5
};

/* Estilo de subrayado para etiquetas */
static const unsigned int ulinepad      = 0; /* relleno horizontal entre subrayado y etiqueta */
static const unsigned int ulinestroke   = 3; /* grosor/altura del subrayado */
static const unsigned int ulinevoffset  = 0; /* distancia desde el fondo de la barra */
static const int ulineall               = 0; /* 1: mostrar subrayado en todas las etiquetas, 0: solo en activas */


/* Reglas para ventanas */
static const Rule rules[] = {
    /* xprop(1):
     *	WM_CLASS(STRING) = instancia, clase
     *	WM_NAME(STRING) = título
     */
    /* clase      instancia    título       máscara etiquetas  centrado flotante monitor */
    { "Gimp",     NULL,       NULL,       0,            0,           1,           -1 },
    { "firefox",  NULL,       NULL,       1 << 0,       0,           0,           -1 },  // Ventana 1 (tag 0)
    { "VSCodium", NULL,       NULL,       1 << 2,       0,           0,           -1 },  // Ventana 3 (tag 2)
    { "Alacritty",NULL,       NULL,       1 << 1,       0,           0,           -1 },  // Ventana 2 (tag 1)
    { "eww",      NULL,       NULL,       0,            0,           1,           -1 },
};

/* Diseños */
static const float mfact     = 0.50; /* proporción del área maestra [0.05..0.95] */
static const int nmaster     = 1;    /* número de clientes en área maestra */
static const int resizehints = 0;    /* 1: respetar sugerencias de tamaño en redimensionamiento */
static const int lockfullscreen = 1; /* 1: forzar foco en ventana a pantalla completa */

#define FORCE_VSPLIT 1  /* diseño nrowgrid: forzar división vertical de dos clientes */
#include "functions.h"

/* Diseños disponibles */
static const Layout layouts[] = {
    /* símbolo     función de disposición */
    { "",      tile },    /* primera entrada es por defecto */
    { "",      monocle },
    { "",      spiral },
    { "",     dwindle },
    { "",      deck },
    { "",      bstack },
    { "",      bstackhoriz },
    { "",      grid },
    { "",      nrowgrid },
    { "",      horizgrid },
    { "",      gaplessgrid },
    { "",      centeredmaster },
    { "",      centeredfloatingmaster },
    { "",      NULL },    /* sin función de disposición significa comportamiento flotante */
    { NULL,       NULL },
};

/* Definiciones de teclas */
#define MODKEY Mod4Mask  /* Tecla modificadora (normalmente la tecla Windows/Super) */
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* Ayudante para ejecutar comandos shell al estilo pre dwm-5.0 */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* Teclas */
static const Key keys[] = {
    /* modificador                     tecla        función        argumento */

    // brillo y audio
    {0,             XF86XK_AudioLowerVolume,    spawn, {.v = downvol}},    // Baja el volumen 5% (tecla multimedia bajar volumen)
    {0,             XF86XK_AudioMute,          spawn, {.v = mutevol }},   // Alternar mute/desmute (tecla multimedia silencio)
    {0,             XF86XK_AudioRaiseVolume,    spawn, {.v = upvol}},     // Sube el volumen 5% (tecla multimedia subir volumen)
    {0,             XF86XK_MonBrightnessUp,     spawn, {.v = light_up}},  // Aumenta brillo pantalla 5% (tecla multimedia brillo +)
    {0,             XF86XK_MonBrightnessDown,   spawn, {.v = light_down}},// Reduce brillo pantalla 5% (tecla multimedia brillo -)

    // Capturas de pantalla
    {ControlMask|ShiftMask,          XK_s,       spawn, SHCMD("maim --select | xclip -selection clipboard -t image/png")},  // Área seleccionada (Ctrl+Shift+S)
    {ControlMask,                    XK_s,       spawn, SHCMD("maim | xclip -selection clipboard -t image/png")},           // Pantalla completa (Ctrl+S)
    
    // lanzadores
    { MODKEY,                           XK_c,       spawn, SHCMD("rofi -show drun") },
    { MODKEY,                           XK_Return,  spawn, SHCMD("alacritty")},

    // alternar elementos
    { MODKEY,                           XK_f,       togglefullscr,  {0} },         // MODKEY+f: Alternar pantalla completa para ventana actual

    // moverVentanas

    // mover vista
    { MODKEY,                           XK_Left,    shiftview,      {.i = -1 } },
    { MODKEY,                           XK_Right,   shiftview,      {.i = +1 } },

    // cambiar tamaños mfact y cfact
    { MODKEY,                           XK_h,       setmfact,       {.f = -0.05} },
    { MODKEY,                           XK_l,       setmfact,       {.f = +0.05} },
    { MODKEY|ShiftMask,                 XK_h,       setcfact,       {.f = +0.25} },
    { MODKEY|ShiftMask,                 XK_l,       setcfact,       {.f = -0.25} },
    { MODKEY|ShiftMask,                 XK_o,       setcfact,       {.f =  0.00} },

    { MODKEY|ShiftMask,                 XK_j,       movestack,      {.i = +1 } },
    { MODKEY|ShiftMask,                 XK_k,       movestack,      {.i = -1 } },
    { MODKEY|ShiftMask,                 XK_Return,  zoom,           {0} },
    { MODKEY,                           XK_Tab,     view,           {0} },

    // Control de áreas y ventanas con MODKEY + Shift + flechas
    { MODKEY|ShiftMask, XK_Left,  setmfact,   {.f = -0.05} },  // MODKEY+Shift+← : Reducir área maestra (mover división izquierda)
    { MODKEY|ShiftMask, XK_Right, setmfact,   {.f = +0.05} },  // MODKEY+Shift+→ : Aumentar área maestra (mover división derecha)
    { MODKEY|ShiftMask, XK_Down,  movestack,  {.i = +1} },     // MODKEY+Shift+↓ : Mover ventana abajo en el stack
    { MODKEY|ShiftMask, XK_Up,    movestack,  {.i = -1} },     // MODKEY+Shift+↑ : Mover ventana arriba en el stack

    /* ===== CONTROL DE ESPACIOS (GAPS) ===== */
    // Atajos de teclado (en la sección 'keys[]'):
    /* ----- Control BÁSICO ----- */
    { MODKEY|ControlMask, XK_equal,  incrgaps,  {.i = +1 } },  // [Super+Ctrl++] Aumentar TODOS los gaps
    { MODKEY|ControlMask, XK_minus,  incrgaps,  {.i = -1 } },  // [Super+Ctrl+-] Reducir TODOS los gaps

    /* ----- Control AVANZADO ----- */
    // Gaps INTERIORES (entre ventanas):
    { MODKEY|ShiftMask, XK_i,       incrigaps, {.i = +1 } },   // [Super+Shift+i] +1px interior
    { MODKEY|ShiftMask, XK_u,       incrigaps, {.i = -1 } },   // [Super+Shift+u] -1px interior

    // Gaps EXTERIORES (bordes pantalla):
    { MODKEY|ControlMask, XK_o,     incrogaps, {.i = +1 } },   // [Super+Ctrl+o] +1px exterior
    { MODKEY|ControlMask, XK_p,     incrogaps, {.i = -1 } },   // [Super+Ctrl+p] -1px exterior

    /* ----- RESET ----- */
    { MODKEY|ControlMask|ShiftMask, XK_0, defaultgaps, {0} },  // [Super+Ctrl+Shift+0] Resetear gaps

    /* ===== GESTIÓN DE DISEÑOS (LAYOUTS) Y MONITORES ===== */

    // Cambiar a diseños específicos
    { MODKEY, XK_t, setlayout, {.v = &layouts[0]} },          // [Super+t] Layout tile (mosaico estándar)
    { MODKEY|ShiftMask, XK_f, setlayout, {.v = &layouts[1]} }, // [Super+Shift+f] Layout monocle (ventana completa)
    { MODKEY, XK_m, setlayout, {.v = &layouts[2]} },          // [Super+m] Layout spiral (espiral)
    { MODKEY|ControlMask, XK_g, setlayout, {.v = &layouts[10]} }, // [Super+Ctrl+g] Layout gaplessgrid (rejilla sin espacios)
    { MODKEY|ControlMask|ShiftMask, XK_t, setlayout, {.v = &layouts[13]} }, // [Super+Ctrl+Shift+t] Layout floating (flotante)

    // Ciclar entre diseños
    { MODKEY, XK_space, setlayout, {0} },                    // [Super+Espacio] Cambiar al siguiente diseño
    { MODKEY|ControlMask, XK_comma, cyclelayout, {.i = -1} }, // [Super+Ctrl+,] Ciclar al diseño anterior
    { MODKEY|ControlMask, XK_period, cyclelayout, {.i = +1} },// [Super+Ctrl+.] Ciclar al siguiente diseño

    // Gestión de tags (espacios de trabajo)
    { MODKEY, XK_0, view, {.ui = ~0} },                      // [Super+0] Ver todas las ventanas (mostrar todos los tags)
    { MODKEY|ShiftMask, XK_0, tag, {.ui = ~0} },             // [Super+Shift+0] Mover ventana a todos los tags

    // Manejo de múltiples monitores
    { MODKEY, XK_comma, focusmon, {.i = -1} },               // [Super+,] Enfocar monitor izquierdo
    { MODKEY, XK_period, focusmon, {.i = +1} },              // [Super+.] Enfocar monitor derecho
    { MODKEY|ShiftMask, XK_comma, tagmon, {.i = -1} },       // [Super+Shift+,] Mover ventana a monitor izquierdo
    { MODKEY|ShiftMask, XK_period, tagmon, {.i = +1} },      // [Super+Shift+.] Mover ventana a monitor derecho

    // terminar dwm
    { MODKEY|ControlMask,               XK_q,       spawn, SHCMD("killall bar.sh gvn") },

    // cerrar ventana
    { MODKEY,                           XK_q,       killclient,     {0} },


    TAGKEYS(                        XK_1,                      0)
    TAGKEYS(                        XK_2,                      1)
    TAGKEYS(                        XK_3,                      2)
    TAGKEYS(                        XK_4,                      3)
    TAGKEYS(                        XK_5,                      4)

};

/* Definiciones de botones */
/* click puede ser ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, o ClkRootWin */
static const Button buttons[] = {
    /* click                máscara evento   botón          función        argumento */
    { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
    { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
    { ClkWinTitle,          0,              Button2,        zoom,           {0} },
    { ClkStatusText,        0,              Button2,        spawn,          SHCMD("st") },

    /* Opciones para moveorplace:
    *    0 - posición en mosaico relativa al cursor
    *    1 - posición en mosaico relativa al centro de la ventana
    *    2 - el puntero salta al centro de la ventana
    */
    { ClkClientWin,         MODKEY,         Button1,        moveorplace,    {.i = 0} },
    { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
    { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
    { ClkClientWin,         ControlMask,    Button1,        dragmfact,      {0} },
    { ClkClientWin,         ControlMask,    Button3,        dragcfact,      {0} },
    { ClkTagBar,            0,              Button1,        view,           {0} },
    { ClkTagBar,            0,              Button3,        toggleview,     {0} },
    { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
    { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
    { ClkTabBar,            0,              Button1,        focuswin,       {0} },
    { ClkTabBar,            0,              Button1,        focuswin,       {0} },
    { ClkTabPrev,           0,              Button1,        movestack,      { .i = -1 } },
    { ClkTabNext,           0,              Button1,        movestack,      { .i = +1 } },
    { ClkTabClose,          0,              Button1,        killclient,     {0} },
};
