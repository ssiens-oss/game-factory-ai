import uuid

def build_unity(spec):
    build_id = str(uuid.uuid4())
    return {"build_id": build_id, "spec": spec, "path": f"/builds/{build_id}"}
