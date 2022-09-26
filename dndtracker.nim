import jester
import karax / [karaxdsl, vdom]

template kxi(): int = 0
template addEventHandler(n: VNode; k: EventKind; action: string; kxi: int) =
  n.setAttr($k, action)

proc home: string =
  let vnode = buildHtml(tdiv):
    text "DND Power"
  return $vnode

routes:
  get "/":
    resp home
